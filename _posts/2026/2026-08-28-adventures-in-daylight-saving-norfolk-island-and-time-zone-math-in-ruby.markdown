---
layout: post
title: "Adventures in Daylight Saving, Norfolk Island, and Time Zone Math (in Ruby)"
date: 2026-08-28
tags: [ruby, open-source]
comments: true
---
[distance_of_time_in_words](https://github.com/radar/distance_of_time_in_words) is a small Ruby gem that turns two `Time` objects into a human-readable string like "3 days and 4 hours". Two separate bug reports against it this year turned out to be variations on the same theme: computing a duration between two timestamps is not the trivial subtraction it looks like, the moment time zones are involved. Both fixes shipped in [`dotiw` 5.6.0](https://github.com/radar/distance_of_time_in_words/blob/master/CHANGELOG.md#560-20260828).

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

Curious whether this is a `dotiw`-specific mistake or a trap every "humanize a time difference" library falls into, I reproduced both scenarios — the Norfolk Island offset change and the Dublin DST-adjacent case — against similar libraries in JavaScript, Python, Go, Rust, PHP, C#, Java, and Elixir: `date-fns`, `dayjs`, `moment.js`, `humanize`, `arrow`, `go-humanize`, `chrono-humanize`, native `DateTime::diff`, `Carbon`, `Humanizer`, `PrettyTime`, and `Timex`. All the [test code is on GitHub](https://github.com/dblock/tz_test) if you want to run it yourself.

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

## The Common Thread

Both bugs share a shape: a plausible-looking shortcut (`dst?` instead of `utc_offset`, "correct by exactly 1 hour") that works for the overwhelmingly common case and quietly breaks for a specific, real-world edge case that a bug reporter with an unusual time zone eventually ran into. Neither was caught by the existing test suite, because the test suite ran in one time zone, on inputs that never crossed the affected boundaries.

The actual fix was the same in spirit each time: replace the specific assumption with the general, verifiable fact it was standing in for — actual offsets instead of a DST flag, an arbitrary delta instead of a fixed hour. If you maintain a library that touches wall-clock time, it's worth asking, for every "obvious" shortcut in the code, what real-world weirdness it's quietly assuming doesn't exist. `Europe/Dublin` and `Pacific/Norfolk` are more common exceptions to your assumptions than you'd think.
