---
layout: post
title: "Adventures in Daylight Saving, Norfolk Island, and Time Zone Math (in Ruby)"
date: 2026-08-28
tags: [ruby, open-source]
comments: true
---
[distance_of_time_in_words](https://github.com/radar/distance_of_time_in_words) is a small Ruby gem that turns two `Time` objects into a human-readable string like "3 days and 4 hours". Several separate bug reports against it turned out to be variations on the same theme: computing a duration between two timestamps is not the trivial subtraction it looks like, the moment time zones are involved. The first two fixes shipped in [`dotiw` 5.6.0](https://github.com/radar/distance_of_time_in_words/blob/master/CHANGELOG.md#560-20260828); four more followed shortly after in [`dotiw` 5.6.1](https://github.com/radar/distance_of_time_in_words/blob/master/CHANGELOG.md#561-20260909).

## Bug 1: `dst?` Lies When You Least Expect It

[#63](https://github.com/radar/distance_of_time_in_words/issues/63) reported that a duration of one minute was rendered as "less than 1 second" for users in `Europe/Dublin`. The gem's `TimeHash` had a DST correction that looked reasonable:

```ruby
d = largest - smallest
d -= 1.hour if smallest.dst? && !largest.dst?
d += 1.hour if !smallest.dst? && largest.dst?
```

The idea: if a DST transition happened between the two times, `Time` subtraction already accounts for the wall-clock jump, so cancel it back out before splitting the duration into calendar units. That works everywhere except Ireland. `Europe/Dublin` uses an *inverted* DST scheme: its winter time is legally defined as "standard time minus one hour" rather than the more common "standard time is winter, summer is +1". Depending on whether a `Time` was constructed via `Time.at(seconds)` or `datetime.to_time`, `dst?` could report different values for the exact same instant, even though `utc_offset` agreed. The correction fired when it shouldn't have, and a real one-minute gap got silently zeroed out.

Reproducing it doesn't even require mocking `dst?` — just running the example with the right `TZ` set is enough:

```ruby
ENV['TZ'] = 'Europe/Dublin'

start = Time.at(DateTime.now)
finish = DateTime.now + 1.minute

# => "less than 1 second"
# expected: "1 minute"
distance_of_time_in_words(start, finish)
```

The fix ([PR #152](https://github.com/radar/distance_of_time_in_words/pull/152)) was to stop asking "is this DST?" and just compare the actual offsets:

```ruby
def offset_decreased?(smallest, largest)
  smallest.utc_offset > largest.utc_offset
end

def offset_increased?(smallest, largest)
  smallest.utc_offset < largest.utc_offset
end
```

`utc_offset` doesn't care how the `Time` was constructed or what a particular country calls its winter clock — it's just the number of seconds off UTC. Reliable, and it doesn't require knowing anything about `Europe/Dublin`'s specific legal quirk.

## Bug 2: DST Isn't the Only Thing That Changes an Offset

Fixing #63 with `utc_offset` comparisons was more correct, but still baked in an assumption: that any offset change is a ±1 hour DST transition. [#153](https://github.com/radar/distance_of_time_in_words/issues/153) broke that assumption. Running the test suite under `TZ=Pacific/Norfolk` produced a spurious "23 hours and 30 minutes" leaking into results that should have just been a clean calendar distance.

It turns out [Norfolk Island permanently changed its UTC offset from +11:30 to +11:00 on 4 October 2015](https://www.infrastructure.gov.au/territories-regions-cities/territories/norfolk_island/administrator/media/2015/ni-a-mr-201526), announced by the island's Administrator a month earlier — a one-time `tzdata` rule change, not a recurring seasonal transition. The old code's ±1 hour hardcoding had no way to represent a 30-minute, permanent shift.

Again, a real (non-mocked) reproduction is enough — no `dst?` mismatch involved this time, just a genuine historical offset change baked into `tzdata` itself:

```ruby
ENV['TZ'] = 'Pacific/Norfolk'

start = '2015-1-15'.to_time
finish = '2016-3-15'.to_time

# => "1 year, 2 months, 23 hours, and 30 minutes"
# expected: "1 year and 2 months"
distance_of_time_in_words(start, finish, true)
```

The real fix ([PR #154](https://github.com/radar/distance_of_time_in_words/pull/154)) was to stop special-casing "1 hour" and generalize to whatever the actual offset delta is:

```ruby
def offset_delta(smallest, largest)
  largest.utc_offset - smallest.utc_offset
end
```

Here's why that's needed, worked out with real numbers. `start.utc_offset` is `+11:30` (41400 seconds) and `finish.utc_offset` is `+11:00` (39600 seconds). Ruby's `Time` subtraction (`finish - start`) already factors that in: it returns `36,721,800` seconds, which is 425 days and 1800 seconds (30 minutes) — not a clean 425 days. That's correct: 30 real minutes did elapse due to the offset change, so the raw distance is right.

The bug was in the *next* step, where that distance gets split into `years`/`months`/`weeks`/`days`. That calendar breakdown doesn't work from seconds at all — it reads `largest.year`, `largest.month`, `largest.day` and subtracts `smallest`'s, which are plain calendar fields with no concept of UTC offset. Jan 15 to Mar 15 is a clean "1 year, 2 months, 0 days" by the calendar, no remainder. Meanwhile the old buggy code applied its ±1 hour DST correction *before* computing the distance (since it still thought in terms of "1 hour", not the real -1800 second delta), which left the wrong remainder behind: `36,721,800 - 3600 = 36,718,200` seconds, i.e. `424` whole days plus an `84,600`-second (23.5 hour) remainder — reported as "23 hours and 30 minutes". Neither the ±1 hour hardcoding nor the 30-minute reality had anywhere to go once years/months/days had already consumed the calendar-shaped part of the duration, so it leaked out as bogus hours and minutes. Using the real `offset_delta` (-1800, not ±3600) and applying it consistently everywhere the code touches `@distance` removes that artifact entirely, leaving just "1 year and 2 months".

This is a strictly more general version of Bug 1's fix — the "DST transition" case just falls out as `offset_delta` happening to equal ±3600 seconds. Once we stopped assuming *what kind* of offset change was possible, both the recurring and the one-off cases worked with the same code path. The lesson: don't encode a specific real-world cause (DST, 1 hour) into your math when what you actually care about is a more general effect (offset changed, by however much).

## Do Other Languages Have This Problem?

Curious whether this is a `dotiw`-specific mistake or a trap every "humanize a time difference" library falls into, I reproduced both scenarios — the Norfolk Island offset change and the Dublin DST-adjacent case — against similar libraries in JavaScript, Python, Go, Rust, PHP, C#, Java, Elixir, Swift, Objective-C, and Dart: `date-fns`, `dayjs`, `moment.js`, `humanize`, `arrow`, `go-humanize`, `chrono-humanize`, native `DateTime::diff`, `Carbon`, `Humanizer`, `PrettyTime`, `Timex`, `humanizer`, `RelativeDateTimeFormatter`/`DateComponentsFormatter`, and `timeago`. All the [test code is on GitHub](https://github.com/dblock/tz_test) if you want to run it yourself.

Every one of them was clean on the Dublin case, and every one but one was clean on Norfolk too. Here's the Norfolk Island case in JavaScript (`date-fns`) and Python (`humanize`):

```javascript
process.env.TZ = 'Pacific/Norfolk';
const start = new Date(2015, 0, 15);
const finish = new Date(2016, 2, 15);

// => "about 1 year"
formatDistance(start, finish, { includeSeconds: true });
```

```python
os.environ['TZ'] = 'Pacific/Norfolk'
start = datetime(2015, 1, 15, tzinfo=ZoneInfo('Pacific/Norfolk'))
finish = datetime(2016, 3, 15, tzinfo=ZoneInfo('Pacific/Norfolk'))

# => "1 year, 2 months"
humanize.naturaldelta(finish - start)
```

And the Dublin case in Rust (`chrono-humanize`) and PHP (`Carbon`, the closest analog to `dotiw` since it also supports a compound breakdown):

```rust
let dstart = Dublin.with_ymd_and_hms(2024, 10, 27, 1, 59, 30).earliest().unwrap();
let dfinish = dstart + Duration::minutes(1);

// => "in a minute"
HumanTime::from(dfinish.signed_duration_since(dstart))
```

```php
$dstart = Carbon::create(2024, 10, 27, 1, 59, 30, 'Europe/Dublin');
$dfinish = $dstart->copy()->addMinute();

// => "1 minute before"
$dstart->diffForHumans($dfinish);

// => "1 year 2 months" (Norfolk case, compound breakdown, still clean)
Carbon::create(2015, 1, 15, 0, 0, 0, 'Pacific/Norfolk')
    ->diff(Carbon::create(2016, 3, 15, 0, 0, 0, 'Pacific/Norfolk'))
    ->forHumans();
```

C#'s `Humanizer` doesn't attempt a calendar year/month breakdown at all, only weeks/days/hours/minutes, so the Norfolk case has no calendar-shaped bucket to leak into:

```csharp
var norfolk = TimeZoneInfo.FindSystemTimeZoneById("Pacific/Norfolk");
var start = new DateTimeOffset(2015, 1, 15, 0, 0, 0, norfolk.GetUtcOffset(new DateTime(2015, 1, 15)));
var finish = new DateTimeOffset(2016, 3, 15, 0, 0, 0, norfolk.GetUtcOffset(new DateTime(2016, 3, 15)));

// => "60 weeks, 5 days, 30 minutes"
(finish - start).Humanize(precision: 5);
```

Java's `PrettyTime` only ever formats a single instant relative to another ("1 year from now"), so there's no compound breakdown at all to leak into:

```java
ZonedDateTime start = ZonedDateTime.of(2015, 1, 15, 0, 0, 0, 0, ZoneId.of("Pacific/Norfolk"));
ZonedDateTime finish = ZonedDateTime.of(2016, 3, 15, 0, 0, 0, 0, ZoneId.of("Pacific/Norfolk"));

// => "1 year from now"
new PrettyTime(Date.from(start.toInstant())).format(Date.from(finish.toInstant()));
```

Elixir's `Timex`, however, *does* reproduce the bug — same shape as `dotiw`'s original Norfolk failure, just a smaller leftover because it computes the real offset delta instead of hardcoding an hour:

```elixir
{:ok, start} = DateTime.new(~D[2015-01-15], ~T[00:00:00], "Pacific/Norfolk", Tzdata.TimeZoneDatabase)
{:ok, finish} = DateTime.new(~D[2016-03-15], ~T[00:00:00], "Pacific/Norfolk", Tzdata.TimeZoneDatabase)

# => "1 year, 2 months, 30 minutes"
Timex.Format.Duration.Formatters.Humanized.format(
  Timex.Duration.from_seconds(DateTime.diff(finish, start))
)
```

That trailing "30 minutes" is exactly the Norfolk offset delta leaking out, the same artifact `dotiw` used to produce as "23 hours and 30 minutes" before PR #154. It's a good confirmation that the bug isn't a Ruby-specific mistake so much as a natural consequence of building a compound years/months/.../minutes breakdown from a raw second count without accounting for the offset change along the way — most libraries just happen to avoid the compound breakdown (or, in `Carbon`'s case, avoid the bug despite it) rather than being immune to the underlying trap.

I opened [`bitwalker/timex` PR #793](https://github.com/bitwalker/timex/pull/793) with a fix, following the same strategy as `dotiw`'s: instead of formatting an opaque `Duration` (which has already lost all calendar context by the time it reaches the formatter), the fix adds a `format/2` that takes both datetimes directly, computes years/months via real calendar arithmetic, and only converts the true leftover to a duration:

```elixir
Timex.Format.Duration.Formatters.Humanized.format(start, finish)
# => "1 year, 2 months"
```

While testing this fix, I also found that `format/2` crashes if `finish` comes before `start` — negative years/months get passed straight into Gettext's plural translation, which requires a non-negative count. `format/1` has always been sign-independent (`Duration.from_erl({0, -65, 0})` and `Duration.from_erl({0, 65, 0})` both format the same way), so `format/2` should be too. Filed as a follow-up, [`bitwalker/timex` PR #794](https://github.com/bitwalker/timex/pull/794).

`Timex` itself is largely unmaintained at this point — the last push to `main` was mid-2025, and it has more than 70 open issues — so while I was at it, I checked whether a maintained alternative avoids this whole class of bug. [`humanizer`](https://github.com/ivan-podgurskiy/humanizer) is a small, actively developed, English-only library with a `relative_time/2,3` function. It's clean on both the Norfolk and Dublin cases, and it also handles reversed argument order correctly without crashing — it diffs absolute instants and branches on sign rather than doing calendar-aware year/month shifting, which sidesteps the bug class structurally at the cost of using fixed-width buckets (7/30/365 days) for weeks/months/years instead of exact calendar arithmetic. The reproduction is in the same [test repo](https://github.com/dblock/tz_test), under `elixir/humanizer_test/`.

I later extended the reproduction to Swift, Objective-C, and Dart. Swift and Objective-C share the same underlying Foundation implementation: `RelativeDateTimeFormatter`/`NSRelativeDateTimeFormatter` (single-largest-unit "time ago" style) and `DateComponentsFormatter`/`NSDateComponentsFormatter` (a compound breakdown, directly analogous to `dotiw`'s output). All clean — Norfolk, Dublin, reversed order, and zero distance. Dart's `timeago` package is clean too.

One thing initially looked like a fourth bug during that pass, worth mentioning because I got it wrong at first. Given a reversed `(fromDate, toDate)` pair, `NSDateComponentsFormatter` renders:

```objc
NSDateComponentsFormatter *f = [[NSDateComponentsFormatter alloc] init];
f.unitsStyle = NSDateComponentsFormatterUnitsStyleFull;
f.allowedUnits = NSCalendarUnitYear | NSCalendarUnitMonth;
f.calendar = cal; // Pacific/Norfolk

[f stringFromDate:start toDate:finish]  // => "1 year, 2 months"
[f stringFromDate:finish toDate:start]  // => "-1 year, 2 months"
```

That looks inconsistent — surely it should read `"-1 year, -2 months"` if the underlying delta is negative in both fields? But this is actually standard mixed-radix negative notation, the same convention used for negative durations (`-1:30:00` means minus one-and-a-half hours, not "minus one hour plus thirty minutes") or negative degrees/minutes/seconds coordinates: only the leading unit carries the sign, and the rest are magnitudes of that same negative quantity. `NSCalendar` confirms this is intentional: the raw components really are `year=-1, month=-2` underneath, and the formatter correctly collapses that into a single leading sign for display, exactly as it should. Not a bug — see the [test repo](https://github.com/dblock/tz_test) under `objc/` and `swift/` for the full reproduction and reasoning.

The main reason none of the others reproduce the bug is structural: most round to a single largest unit ("about 1 year", "a minute ago") instead of building a compound breakdown across years, months, weeks, days, hours, *and* minutes the way `dotiw` does. With nowhere calendar-shaped for a stray 30 minutes or 23 hours to end up, there's no remainder left to misattribute. `Carbon` is the exception that proves the rule: it does support a compound breakdown similar to `dotiw`'s output, and still gets it right, because the offset math happens correctly underneath, at the `DateInterval` level, before any splitting into units occurs.

One other thing stood out while testing the Dublin case in Rust and C#. Both refuse to let you construct a local time that falls in an ambiguous window (the "fall back" hour that occurs twice) without handling it explicitly. Rust's `chrono-tz`:

```rust
match Dublin.with_ymd_and_hms(2024, 10, 27, 1, 59, 30) {
    chrono::LocalResult::Single(dt) => println!("Single: {}", dt),
    chrono::LocalResult::Ambiguous(a, b) => println!("Ambiguous: {} OR {}", a, b),
    chrono::LocalResult::None => println!("None (doesn't exist, e.g. spring-forward gap)"),
}
# => Ambiguous: 2024-10-27 01:59:30 IST OR 2024-10-27 01:59:30 GMT
```

And .NET's `TimeZoneInfo`, which surfaces the same fact via an explicit query instead of an enum:

```csharp
var dublin = TimeZoneInfo.FindSystemTimeZoneById("Europe/Dublin");
var local = new DateTime(2024, 10, 27, 1, 59, 30, DateTimeKind.Unspecified);

dublin.IsAmbiguousTime(local); // => true
dublin.GetAmbiguousTimeOffsets(local); // => [00:00:00, 01:00:00]
```

Ruby (and most of the other languages tested) will silently pick one interpretation of an ambiguous wall-clock time and move on. Forcing the caller to disambiguate explicitly is exactly the kind of design that would have made a bug like #63 harder to write in the first place.

## Bug 3: Two Unrelated Offsets Aren't a Transition

`offset_delta` from Bug 2 fixed the "real transition" case, but it introduced a subtler mistake: it assumed *any* two `Time` values with different `utc_offset`s must represent the same clock crossing a real transition, and folded the difference in unconditionally. [#160](https://github.com/radar/distance_of_time_in_words/issues/160) showed that's not true. Comparing a `Time` pinned to UTC against a `Time` pinned to a fixed `-08:00` offset — two clocks that have nothing to do with each other, no shared tzdata history, no transition between them — still triggered the same folding logic:

```ruby
start = Time.utc(2026, 1, 15, 12, 0, 0)
finish = Time.new(2026, 1, 15, 12, 0, 30, '-08:00')

# => "less than 1 second" (8 hours silently subtracted)
# expected: "8 hours"
distance_of_time_in_words(start, finish)
```

The fix ([PR #161](https://github.com/radar/distance_of_time_in_words/pull/161)) added a `same_clock?` guard before applying `offset_delta` at all — only fold the offset when both `Time`s plausibly represent observations of the *same* underlying clock (same system zone abbreviation, both non-UTC, etc.), not merely because they happen to disagree on offset:

```ruby
def offset_delta(smallest, largest)
  return 0 unless same_clock?(smallest, largest)

  largest.utc_offset - smallest.utc_offset
end
```

## Bug 4: `to_time` Doesn't Always Mean the Same Thing

Shipping `same_clock?` immediately raised the next question: what actually counts as "the same clock"? [#162](https://github.com/radar/distance_of_time_in_words/issues/162) is a case where two `ActiveSupport::TimeWithZone` values, in two different named zones (`Asia/Tokyo` and `America/Los_Angeles`), get converted to plain `Time` via `#to_time` before reaching `dotiw`. The `Time#zone` accessor is normally a `String` (a zone abbreviation like `"JST"`) or `nil` for a fixed offset — `same_clock?` treated any two non-nil `#zone`s as good enough. That was true until Rails 8.0, where `to_time_preserves_timezone = :zone` became the default (permanent as of 8.2): `TimeWithZone#to_time` now returns a plain `Time` whose `#zone` is the actual `ActiveSupport::TimeZone` *object*, not a string. Two different zone objects both being "not nil" made `same_clock?` say yes to two completely unrelated zones, and the real 1-hour difference between Tokyo and Los Angeles got folded away into "less than 1 second" again — but only on Rails >= 8.0. Reproducing it needed the Rails 8 code path specifically:

```ruby
tokyo_time = ActiveSupport::TimeZone['Asia/Tokyo'].local(2026, 1, 16, 4, 0, 0).to_time
la_time = ActiveSupport::TimeZone['America/Los_Angeles'].local(2026, 1, 15, 12, 0, 0).to_time

# On Rails >= 8.0: tokyo_time.zone and la_time.zone are both TimeZone objects (not strings),
# so the old same_clock? treated them as "the same clock" and folded the 1-hour gap away.
# => "less than 1 second" on Rails >= 8.0, "1 hour" on Rails <= 7.2
distance_of_time_in_words(tokyo_time, la_time)
```

The fix ([PR #163](https://github.com/radar/distance_of_time_in_words/pull/163)) taught `same_clock?` to actually compare the zone objects for equality instead of just checking they're both present:

```ruby
def same_clock?(smallest, largest)
  if smallest.respond_to?(:time_zone) || largest.respond_to?(:time_zone)
    smallest.respond_to?(:time_zone) && largest.respond_to?(:time_zone) &&
      smallest.time_zone == largest.time_zone
  elsif !smallest.zone.is_a?(String) || !largest.zone.is_a?(String)
    !smallest.zone.nil? && smallest.zone == largest.zone
  else
    !smallest.zone.nil? && !smallest.utc? && !largest.zone.nil? && !largest.utc?
  end
end
```

This one is a good reminder that a library's own dependencies can quietly change the shape of the objects you're handed. `dotiw` never called `to_time` itself — a Rails minor version bump changed what `Time#zone` returns for values constructed elsewhere entirely, and the bug only showed up for people on the new default.

## Bringing In More Test Cases

Since both of these bugs turned out to have prior art elsewhere, I went back through the test suites of the libraries surveyed for Bug 2/3 — `Luxon`'s diff tests, `Timex`'s humanized-duration tests, and the `tz_test` reproductions — and pulled in the ones that translate directly into `dotiw` regression examples: a UTC-vs-CEST offset comparison from Luxon ([PR #166](https://github.com/radar/distance_of_time_in_words/pull/166)) and the historical Norfolk Island offset change ([PR #167](https://github.com/radar/distance_of_time_in_words/pull/167)), both passing cleanly against the fixed `same_clock?`/`offset_delta`. (These started life bundled together in a single PR #164, later split apart once it became clear the third example below needed materially different treatment.)

The Timex-derived case — a `Europe/Dublin` DST fall-back, one real minute elapsing across the clocks-back transition — turned up a fifth wrinkle while adapting it: `same_clock?` correctly recognizes both timestamps as the *same* clock (they really are the same `TimeZone` object), so `offset_delta` still folds in the full 1-hour offset change. But here the *actual* elapsed time is only 60 seconds — smaller than the offset delta being folded in — so the correction overshoots and produces a negative corrected distance, again collapsing to "less than 1 second" instead of "1 minute". Unlike Bugs 3 and 4, this isn't about misidentifying *whether* two `Time`s are the same clock; it's that the folding math assumes the real elapsed time is always large relative to the offset shift, which breaks down right at the boundary of a transition. Filed as [#165](https://github.com/radar/distance_of_time_in_words/issues/165) and fixed in [PR #169](https://github.com/radar/distance_of_time_in_words/pull/169): the offset correction now only ever applies to the sub-day leftover, once the distance has already been split into calendar fields, rather than to the top-level distance used to decide which calendar branch (`build_years`, `build_days`, etc.) to take in the first place — so a genuinely tiny elapsed time can no longer be pushed past zero by a much larger offset shift.

## Bug 5: An Unforced Conversion, Not a Rails Version Limitation

Verifying the #165 fix across every supported Rails version turned up one more thing. The regression spec for #165's sibling case — the Norfolk historical offset change, this time expressed as `ActiveSupport::TimeWithZone` values rather than plain `Time` — only passed on Rails >= 8.0. On Rails < 8.0, it failed with a spurious "1 year, 2 months, and 30 minutes" instead of "1 year and 2 months", suspiciously similar to the very bug #154 had already fixed. I was pairing with an AI coding assistant on this fix, and its first instinct was to shrug this off as an inherent Rails < 8.0 limitation (the same `to_time_preserves_timezone` distinction from Bug 4) and skip the spec on older Rails.

That instinct was wrong, and it took me pushing back — "the following code should always give the correct answer, no?" — before it looked closer instead of accepting its own shortcut. The real cause: `distance_of_time_in_words` unconditionally called `#to_time` on any `TimeWithZone` argument before doing anything else with it:

```ruby
from_time = from_time.to_time if !from_time.is_a?(Time) && from_time.respond_to?(:to_time)
```

On Rails < 8.0, `TimeWithZone#to_time` (without `to_time_preserves_timezone` set) returns a plain `Time` in the *process's local system zone*, discarding the actual zone entirely — which is exactly the information `same_clock?` needs to recognize two readings as the same clock across a transition. But nothing about `TimeHash` actually needs a plain `Time` in the first place: `TimeWithZone` already supports every operation it performs — subtraction, `#advance`, `#year`/`#month`/`#day`/`#hour`, `#utc_offset` — without ever being converted. The `#to_time` call wasn't a Rails-version workaround at all, just an unforced, avoidable conversion that happened to only cause visible damage before Rails 8.0's default changed what it produced.

Filed as [#170](https://github.com/radar/distance_of_time_in_words/issues/170) and fixed in [PR #167](https://github.com/radar/distance_of_time_in_words/pull/167) with a `coerce_to_time` helper that leaves `Time` and `TimeWithZone` arguments untouched, only calling `#to_time` on genuinely non-`Time`-like values (`Date`, `DateTime`):

```ruby
def coerce_to_time(value)
  return value if value.is_a?(Time) || value.respond_to?(:time_zone)

  value.respond_to?(:to_time) ? value.to_time : value
end
```

With that in place, the Norfolk `TimeWithZone` example (and the #165 Dublin fall-back example) both pass on every supported Rails version, 7.0 through 8.1, with no skip required — a stronger fix than the version-gated one I'd initially assumed was necessary.

## The Common Thread

All three failure modes share a shape: a plausible-looking shortcut (`dst?` instead of `utc_offset`, "correct by exactly 1 hour", "convert to a plain `Time` up front") that works for the overwhelmingly common case and quietly breaks for a specific, real-world edge case that a bug reporter with an unusual time zone eventually ran into. None were caught by the existing test suite, because the test suite ran in one time zone, on inputs that never crossed the affected boundaries — and, in Bug 5's case, on only one version of Rails.

The actual fix was the same in spirit each time: replace the specific assumption with the general, verifiable fact it was standing in for — actual offsets instead of a DST flag, an arbitrary delta instead of a fixed hour, and no conversion at all where none was ever needed. If you maintain a library that touches wall-clock time, it's worth asking, for every "obvious" shortcut in the code, what real-world weirdness it's quietly assuming doesn't exist — and, per Bug 5, whether "this only works on newer Rails" is really a platform limitation or just an unforced move your own code is making. `Europe/Dublin` and `Pacific/Norfolk` are more common exceptions to your assumptions than you'd think.
