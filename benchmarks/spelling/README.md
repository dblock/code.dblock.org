# Spelling benchmarks

These benchmarks measure two different things: full-archive spelling tools and direct dictionary checks. Full-tool timings include process startup, parsing, dictionary loading, and spelling checks. Direct-engine timings isolate dictionary work and cannot predict full-tool performance.

Measurements were taken locally on macOS with Ruby 3.3.5 and dependencies already installed. The RuboCop result cache was disabled for every full-tool run.

## Current result: released 0.2.0

On October 21, 2026, released `rubocop-spellcheck` 0.2.0 checked all **618 tracked Markdown files** on this branch, including this README, hidden paths, and `_styles/proselint/README.md`. Title front matter and embedded Ruby strings were checked; identifiers were disabled. All three runs passed with zero findings.

| Full-archive tool | Run 1 | Run 2 | Run 3 | Average |
| --- | ---: | ---: | ---: | ---: |
| `rubocop-spellcheck` 0.2.0 | 3.695s | 3.719s | 3.656s | **3.690s** |

PySpelling and the direct dictionary engines were not rerun for this release. Their historical results below use different configurations or file contents and are not a fresh comparison against 0.2.0.

An earlier October 21 run in the blog worktree used development commit `ac24948`, whose runtime code was subsequently released as 0.2.0. It averaged **3.722s** (3.699 / 3.784 / 3.684s), with zero findings across 618 files. That corpus included the draft introduction instead of this benchmark README.

## Reproduce

### Released Ruby tool only

Install the branch's Bundler dependencies, then run:

```sh
bundle install
python3 benchmarks/spelling/tools.py --tool rubocop-spellcheck
```

This does not require PySpelling, Aspell, or PyYAML. Use `--runs 1` for a single run; the default is three.

### Both full-archive tools

Also install PySpelling with its Markdown filter dependencies, PyYAML, and Aspell with English dictionaries:

```sh
python3 benchmarks/spelling/tools.py
```

Use `--tool pyspelling` to run only PySpelling. Its configuration comes from pre-migration commit `35bde6f7ec1b32a111e3c20471fcef3e8f87c657`, with an explicit source list and the branch's project vocabulary. Extraction rules and English dictionaries differ between the two tools.

The full-tool harness copies tracked `.md` and `.markdown` files and current configuration into a temporary snapshot. It includes dotfiles, `.github`, `_styles`, and this README regardless of normal archive exclusions. Each tool must inspect exactly the discovered file count. Results include exit codes: a run with spelling findings is not a clean performance baseline. Temporary snapshots are automatically removed.

### Direct dictionary engines

```sh
bundle exec ruby benchmarks/spelling/kotoshu.rb
```

The native extension shipped with `Kotoshu` must be available; this benchmark fails explicitly if it is not. It calls `Kotoshu::Native::Dictionary` directly, not a standalone Rust CLI. Pure Ruby explicitly uses `backend: 'ruby'`. No resource downloads occur.

The engine harness extracts words once using the installed spellchecker's Markdown extractor, then checks the same distinct words with both engines and the same dictionary and project vocabulary. Project vocabulary matches bypass dictionary calls. Extraction is timed separately; dictionary timings exclude process startup, RuboCop investigation, source mapping, and suggestions.

Both scripts print measurements and write ignored JSON results beside themselves. The full-tool harness also writes ignored logs. Reruns use current files and configuration, so they will not exactly reproduce historical corpora.

## Historical full-tool results

### PR #14: dictionary reuse

On October 20, 2026, [PR #14](https://github.com/dblock/rubocop-spellcheck/pull/14) at `42c6e60f7c2be0c4f253385c7e8731833a816170` reused dictionaries and word verdicts across files instead of rebuilding them for every file.

Both tools checked the same **618 tracked Markdown files** from blog commit `c76c7a6`, before its results section was added. Front matter was disabled for RuboCop. All runs passed with zero findings.

| Full-archive tool | Run 1 | Run 2 | Run 3 | Average |
| --- | ---: | ---: | ---: | ---: |
| PySpelling / Aspell | 77.662s | 77.003s | 66.806s | 73.824s |
| `rubocop-spellcheck` PR #14 | 3.294s | 3.577s | 3.321s | 3.397s |

For this historical comparison, the PR implementation was **21.73 times faster** than PySpelling.

### Initial 0.1.0 baseline

The original runs used blog commit `e273fe0940d6052afb3658d0d549c09db148dc4f` and the vocabulary available then. Front matter was disabled for RuboCop. All checks passed, but the tools did not inspect identical file sets.

| Full-archive tool | Files | Run 1 | Run 2 | Run 3 | Average |
| --- | ---: | ---: | ---: | ---: | ---: |
| PySpelling / Aspell | 614 | 63.798s | 65.418s | 65.230s | 64.815s |
| `rubocop-spellcheck` 0.1.0 | 616 | 209.106s | 218.102s | 202.327s | 209.845s |

The original PySpelling glob omitted `.github/ISSUE_TEMPLATE/broken_links.md` and `tags/.net.md`. After source discovery was corrected, a diagnostic run inspected 617 files per tool: PySpelling took 72.827s and `rubocop-spellcheck` took 210.293s. Both reported findings in the newly added README, so that run verified file coverage rather than a clean timing baseline.

## Historical direct-engine results

These October 20 measurements used `Kotoshu` 1.0.8 and its `kotoshu-rs` 0.2.3 native extension. Front matter, code, destinations, and addresses were excluded from extraction. Both engines reported zero misspelled tokens or words in the two clean datasets below.

### PR #14 dataset: 618 files

Extraction took **1.136s** for 201,517 tokens and 14,145 distinct case-sensitive words.

| Engine | Load, runs 1 / 2 / 3 | Distinct-word check, runs 1 / 2 / 3 | Average distinct-word check |
| --- | --- | --- | ---: |
| Pure Ruby | 0.267315 / 0.202550 / 0.199191s | 0.319022 / 0.354248 / 0.377021s | 0.350097s |
| Rust native extension | 0.026594 / 0.025025 / 0.024154s | 0.048733 / 0.048772 / 0.047611s | 0.048372s |

Replaying cached verdicts across all tokens took 0.014-0.015s per run.

### Initial dataset: 616 files

Extraction produced 200,770 tokens and 14,038 distinct case-sensitive words; extraction time was not recorded.

| Engine | Load, runs 1 / 2 / 3 | Distinct-word check, runs 1 / 2 / 3 | Average distinct-word check |
| --- | --- | --- | ---: |
| Pure Ruby | 0.297378 / 0.199777 / 0.200838s | 0.325729 / 0.335563 / 0.341524s | 0.334272s |
| Rust native extension | 0.026604 / 0.023531 / 0.022927s | 0.049325 / 0.045843 / 0.043656s | 0.046275s |

Cached replay took 0.013-0.017s per run. The Rust distinct-word check was approximately **7.22 times faster**; that ratio excludes the rest of the spelling workflow.
