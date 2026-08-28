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

## The Common Thread

Both bugs share a shape: a plausible-looking shortcut (`dst?` instead of `utc_offset`, "correct by exactly 1 hour") that works for the overwhelmingly common case and quietly breaks for a specific, real-world edge case that a bug reporter with an unusual time zone eventually ran into. Neither was caught by the existing test suite, because the test suite ran in one time zone, on inputs that never crossed the affected boundaries.

The actual fix was the same in spirit each time: replace the specific assumption with the general, verifiable fact it was standing in for — actual offsets instead of a DST flag, an arbitrary delta instead of a fixed hour. If you maintain a library that touches wall-clock time, it's worth asking, for every "obvious" shortcut in the code, what real-world weirdness it's quietly assuming doesn't exist. `Europe/Dublin` and `Pacific/Norfolk` are more common exceptions to your assumptions than you'd think.
