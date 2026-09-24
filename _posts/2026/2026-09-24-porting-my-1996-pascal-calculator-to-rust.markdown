---
layout: post
title: "Porting My 1996 Pascal Calculator to Rust"
date: 2026-09-24
tags: [ai, rust, open-source]
---

In his [Rails World 2026 keynote](https://www.youtube.com/watch?v=vDjW_dRyKXY) DHH talks about one-shot apps built almost instantly with an agent as part of [Omarchy](https://omarchy.org/). His canonical example is [Omacalc](https://github.com/omacom/omacalc), a dead simple calculator. It's a good demo and not a hard problem. Let's take it further and rewrite a more advanced calculator in Rust that we can also run as an MCP server, so an AI coding agent can outsource arithmetic to it instead of hallucinating a square root.

In 1994 I wrote an expression evaluator for a lab assignment. It grew into [Expression Calculator](https://web.archive.org/web/20031213112526/http://excalc.vestris.com/), a shareware Windows app I sold through a company I co-founded, Vestris Inc. In 1997 it got pressed onto a CD-ROM and sold 3,000 copies in Germany under the name Global Calculator. I made money and users wrote fan mail. This week, Copilot and I ported its Pascal/Delphi core to Rust as [excalc-rs](https://github.com/dblock/excalc-rs) ([crates.io](https://crates.io/crates/excalc)), a CLI and MCP server, in under 24 hours.

Both the port and the original are mathematical beasts. They can:

- Chain 12 comparison and logical/bitwise operators, and 12 arithmetic operators with correct precedence
- Fit 8 general/rounding functions and 7 statistics functions (mean, variance, standard deviation)
- Evaluate 36 standard math functions: trig, inverse trig, and hyperbolic variants, both in radians and degrees
- Answer 17 number theory questions: GCD/LCM, Fibonacci, primality, Mersenne and perfect numbers, Euler's totient
- Run 18 financial functions: NPV, IRR, loan payments, present/future value, depreciation schedules
- Numerically integrate anything via 7 quadrature methods (trapezoid, Simpson, Gaussian, and more)
- Compute 21 advanced/special functions: the Gamma and Beta functions, elliptic integrals, Fresnel integrals, the error function, dilogarithm, Dawson's integral, sine and cosine integrals

Let's verify that Euler's Gamma function is the continuous extension of the factorial (`Γ(n) = (n-1)!`), and comes back essentially zero (floating-point noise from numeric integration):

```
calc 'gamma(10) - 9!'
# 0.000000054249539971351624
```

`Γ(10)` equals `9!` to 7 decimal places, computed via numeric integration rather than table lookup.

Check out the [docs/](https://github.com/dblock/excalc-rs/blob/master/docs/README.md).

### The 1996 Original

![Expression Calculator 2.43 for Windows](/images/posts/2026/2026-09-24-porting-my-1996-pascal-calculator-to-rust/calc.jpg)

The original was *years* of work. The Pascal source code is [on GitHub](https://github.com/dblock/excalc), open-sourced in 2009 once Vestris wound down in its original British Virgin Islands offshore incarnation. The core `common/MCalc.pas` is a 4,036 lines long evaluator. The full Windows app, UI included, is 10,339 lines of Pascal across the repo, backed by a 189-page [user's guide](https://web.archive.org/web/20040129021441/http://excalc.vestris.com/docs/pdf/excalc.pdf) I apparently wrote it in XEmacs and typeset with SgmlTools. I have no memory of most of this code or the math behind it. It's 30 years old. I was 20.

### The 2026 Port

The Rust port's git history is one Copilot CLI session, 145 turns, spread over 24 hours:

```
2026-09-23 20:46  Initial scaffold: core arithmetic engine, standard math, statistics
2026-09-23 20:47  Add CI: build/test on Linux/macOS/Windows, fmt + clippy checks
2026-09-23 20:53  Release v0.1.0
2026-09-23 21:14  Add test coverage reporting to CI via cargo-llvm-cov and Coveralls
2026-09-23 21:38  Add MCP server exposing evaluate as a stdio tool
2026-09-23 22:29  Implement general/rounding functions (abs, frac, intg, round, trunc, ceil, floor, random)
2026-09-23 22:53  Add comparison and logical/bitwise operators
2026-09-23 23:16  Implement advanced / special functions
2026-09-23 23:32  Implement financial functions
2026-09-23 23:43  Implement general-purpose numeric integration
2026-09-24 06:07  Add short descriptions to every README example
2026-09-24 06:27  Implement variable assignment (:=)
2026-09-24 07:24  Add degree/radian conversion and degree-native trig functions
2026-09-24 07:59  Add Homebrew formula and CI validation
2026-09-24 08:09  Add Windows MSI installer via cargo-wix
2026-09-24 08:22  Release v0.2.0
```

The first `v0.1.0` cut that did basic math shipped 7 minutes after the initial scaffold. I slept for 6 hours and [went out on a run](https://www.strava.com/activities/20308922776). The complete port totaled 59 commits, 5,060 lines of Rust, 217 tests, and a `v0.2.0` published to [crates.io](https://crates.io/crates/excalc), tapped on [Homebrew](https://github.com/dblock/excalc-rs#macoslinux), and shipped as a Windows MSI, by the morning.

The token bill for the port was 732 API calls across the session, ~83 million input tokens processed (~80 million of those were cache reads), and about 262,000 output tokens at a rough napkin math cost estimate of $50. Pretty great ROI given that I sold the original Expression Calculator for $25 a copy!

### Some Interesting Math

Much of the advanced math in the calculator was taught by professors Ernst Hairer and Gerhard Wanner from their book, [_Analysis by Its History_](https://www.unige.ch/~wanner/analysis.html). I took the course as an undergrad.

For example, the book spends real time on elliptic integrals, which get their name from the problem of computing the arc length of an ellipse, a problem with no elementary closed form. `excalc-rs` implements `ellipticE`, the incomplete elliptic integral of the second kind, exactly as the original Pascal did as a numeric integration, not a series approximation:

```
calc "4 * 5 * ellipticE(0.8)"
# 25.52699886339813
```

That's the circumference of an ellipse with semi-major axis 5 and semi-minor axis 3 (eccentricity `sqrt(1 - 3^2/5^2) = 0.8`), a number with no closed form, computed by adaptive quadrature under the hood, the same way `ci`, `chi`, `erf`, and a dozen other special functions are as thin wrappers around a shared `int(expression, variable, lowerBound, upperBound, tolerance)` engine. See [docs/functions/advanced.md](https://github.com/dblock/excalc-rs/blob/master/docs/functions/advanced.md).

### Try It Out

```bash
cargo install excalc
calc "sqrt(16) + sin(pi/2)"
# 5
```

Use `brew tap dblock/excalc-rs https://github.com/dblock/excalc-rs` and `brew install excalc` on macOS/Linux, or grab the MSI from the [latest release](https://github.com/dblock/excalc-rs/releases/latest) on Windows.

### Links

- [excalc-rs](https://github.com/dblock/excalc-rs), the Rust port
- [dblock/excalc](https://github.com/dblock/excalc), the original Pascal/Delphi source
- [excalc-rs on crates.io](https://crates.io/crates/excalc)
- [HISTORY.md](https://github.com/dblock/excalc-rs/blob/master/HISTORY.md), the full story of Expression Calculator and Global Calculator
- [port/DESIGN.md](https://github.com/dblock/excalc-rs/blob/master/port/DESIGN.md) and [port/PROMPTS.md](https://github.com/dblock/excalc-rs/blob/master/port/PROMPTS.md), the design decisions and full prompt history behind the port
