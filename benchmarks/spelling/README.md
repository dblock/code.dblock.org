# Spelling benchmarks

Measurements taken locally on macOS with Ruby 3.3.5 on October 20, 2026. Dependencies were already installed. These are different benchmark layers, not four interchangeable end-to-end tools.

## Released 0.2.0: full-tool benchmarks

The branch now uses released `rubocop-spellcheck` 0.2.0 with title front matter and embedded Ruby string checking enabled. Identifiers remain disabled. Full-tool timings include process startup, parsing, dictionary loading, and spelling checks, with RuboCop caching disabled.

### Earlier blog-worktree measurement

The October 21 blog-worktree benchmark used development commit `ac24948`, whose runtime code was subsequently released as 0.2.0. It checked 618 tracked Markdown files in 3.699 / 3.784 / 3.684 seconds, averaging **3.722 seconds**, with no findings. That corpus included the draft introduction but not this benchmark README. This is not the fresh released-gem branch run.

### Reproducing the released-gem branch measurement

Measured October 21, 2026 on macOS with Ruby 3.3.5 and released `rubocop-spellcheck` 0.2.0. All three runs checked 618 tracked Markdown files with zero findings.

| Full-archive tool | Run 1 | Run 2 | Run 3 | Average |
| --- | ---: | ---: | ---: | ---: |
| Released `rubocop-spellcheck` 0.2.0 | 3.695s | 3.719s | 3.656s | **3.690s** |

Run only the Ruby tool without installing PySpelling, Aspell, or PyYAML:

```sh
python3 benchmarks/spelling/tools.py --tool rubocop-spellcheck
```

Branch runs include this README, not the uncommitted draft introduction. PySpelling and direct dictionary engines are separate benchmarks; the historical results below must not be interpreted as fresh 0.2.0 measurements.

## Historical PR 14: full-tool and direct-engine benchmarks

These historical runs pinned [rubocop-spellcheck PR #14](https://github.com/dblock/rubocop-spellcheck/pull/14) at `42c6e60f7c2be0c4f253385c7e8731833a816170`. The fix reuses dictionaries and word verdicts across files instead of rebuilding them for each file.

These runs used the blog files from `c76c7a6` before adding this results section. Both full tools checked all **618 tracked Markdown files**, including hidden paths, the benchmark README, and `_styles/proselint/README.md`. All runs passed with zero spelling findings. Earlier benchmark discovery excluded `_styles`, so those historical counts are lower.

| Full-archive tool | Run 1 | Run 2 | Run 3 | Average |
| --- | ---: | ---: | ---: | ---: |
| PySpelling / Aspell | 77.662s | 77.003s | 66.806s | 73.824s |
| rubocop-spellcheck PR #14 | 3.294s | 3.577s | 3.321s | 3.397s |

The PR implementation was approximately **21.73 times faster** than PySpelling on the same files. The RuboCop result cache was disabled. Compared with the historical 0.1.0 average of 209.845s below, this is approximately 61.77 times faster, though that older run used a smaller corpus.

Direct-engine extraction took **1.136s** for 201,517 tokens and 14,145 distinct case-sensitive words. Both engines reported zero misspelled tokens or words.

| Engine | Load, runs 1 / 2 / 3 | Distinct-word check, runs 1 / 2 / 3 | Average distinct-word check |
| --- | --- | --- | ---: |
| `Kotoshu` 1.0.8, pure Ruby | 0.267315 / 0.202550 / 0.199191s | 0.319022 / 0.354248 / 0.377021s | 0.350097s |
| `kotoshu-rs` 0.2.3, native extension | 0.026594 / 0.025025 / 0.024154s | 0.048733 / 0.048772 / 0.047611s | 0.048372s |

Cached replay took 0.014–0.015 seconds per run. The direct-engine methodology and limitations below still apply; these dictionary timings exclude full-tool overhead.

## Historical full-archive tools

The original measurements used blog commit `e273fe0940d6052afb3658d0d549c09db148dc4f`. All checks passed.

| Tool | Run 1 | Run 2 | Run 3 | Average |
| --- | ---: | ---: | ---: | ---: |
| PySpelling / Aspell | 63.798s | 65.418s | 65.230s | 64.815s |
| rubocop-spellcheck 0.1.0 | 209.106s | 218.102s | 202.327s | 209.845s |

Both ran in an isolated temporary snapshot using the current project vocabulary. PySpelling used the pre-migration configuration from `35bde6f7ec1b32a111e3c20471fcef3e8f87c657`; RuboCop used the current spelling cop with its cache disabled and explicit Markdown paths. Front matter was disabled for RuboCop; the extraction pipelines and English dictionaries differ.

PySpelling checked 614 files. Its original glob omitted `.github/ISSUE_TEMPLATE/broken_links.md` and `tags/.net.md`; RuboCop checked 616. RuboCop took approximately 3.24 times as long. This is not a dictionary-engine-only comparison.

## Historical direct `Kotoshu` engine checks

Extracted the 616 files once using rubocop-spellcheck's Markdown extractor and English word pattern: 200,770 tokens, 14,038 distinct case-sensitive words. Front matter, code, destinations, and addresses were excluded. Both implementations used rubocop-spellcheck's bundled English dictionary and the same case-insensitive project vocabulary.

| Engine | Load, runs 1 / 2 / 3 | Distinct-word check, runs 1 / 2 / 3 | Average distinct-word check |
| --- | --- | --- | ---: |
| `Kotoshu` 1.0.8, pure Ruby | 0.297378 / 0.199777 / 0.200838s | 0.325729 / 0.335563 / 0.341524s | 0.334272s |
| `kotoshu-rs` 0.2.3, native extension | 0.026604 / 0.023531 / 0.022927s | 0.049325 / 0.045843 / 0.043656s | 0.046275s |

The Rust engine was called directly through `Kotoshu::Native::Dictionary`, the native extension shipped in the installed `Kotoshu` gem, not a standalone Rust CLI. Pure Ruby explicitly used `backend: 'ruby'`. Both reported zero misspelled words. Replaying the cached verdicts across all tokens took 0.013–0.017 seconds per run.

Distinct words were checked once, as rubocop-spellcheck caches word verdicts. Project vocabulary matches short-circuited dictionary calls. The direct timing excludes Markdown extraction, process startup, RuboCop investigation, source mapping, and suggestions. The Ruby/Rust dictionary comparison is approximately 7.22 times faster for Rust, but does not predict the speedup of the whole spelling workflow. The original direct-engine run did not time extraction separately.

## Reproduce

Install the blog's Bundler dependencies, PySpelling with its Markdown filter dependencies, and Aspell with English dictionaries. The `Kotoshu` native extension must be available; the engine benchmark fails explicitly if it is not. No resource downloads occur during the engine benchmark.

```sh
python3 benchmarks/spelling/tools.py
bundle exec ruby benchmarks/spelling/kotoshu.rb
```

The scripts discover all tracked `.md` and `.markdown` files, including dotfiles, files under `.github`, tracked files under `_styles`, and this benchmark documentation. No tracked Markdown paths are excluded. PySpelling receives an explicit source list instead of the old glob so it cannot omit hidden paths. Both full-tool checks must report exactly the discovered file count or the benchmark fails.

The scripts print measurements and write ignored JSON results alongside themselves. The full-tool script also writes ignored logs. Temporary snapshots are automatically removed. The engine script additionally records extraction time on subsequent runs. The historical measurements above predate this explicit-source correction; rerun the scripts for a strict same-file comparison.

## Explicit-source verification

After correcting source discovery, one full-tool run verified 617 files for each tool, including the new benchmark README: PySpelling took 72.827s and rubocop-spellcheck took 210.293s. Both returned spelling findings in this README (unquoted engine names), which were subsequently formatted as code. This verifies full file coverage, not identical spelling decisions.

The corresponding direct-engine run extracted 201,200 tokens and 14,063 distinct words in 1.085s. Ruby distinct-word checks took 0.305018 / 0.322419 / 0.361463s; Rust took 0.045242 / 0.045809 / 0.048407s. Both found the same five flagged tokens across three distinct words. These measurements include the README before its final edits; subsequent runs naturally include those edits.
