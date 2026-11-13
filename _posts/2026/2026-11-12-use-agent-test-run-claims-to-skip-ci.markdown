---
layout: post
title: "Use Agent Test Run Claims to Skip CI"
date: 2026-11-12
tags: [open-source, github-actions, testing, ai]
---
An AI agent runs the test suite and lints in its local checkout. Then, you open a pull request and GitHub Actions runs the same checks against the same commit. This is wasteful, so I built [already-tested](https://github.com/dblock/already-tested) to submit agent claims with PRs and skip CI workflows. This is also called "shift left".

<img src="/images/posts/2026/2026-11-12-use-agent-test-run-claims-to-skip-ci/logo.svg" alt="Already Tested logo: a green rubber stamp with a check mark" width="160">

Of course, anyone who can edit the pull-request description can forge a claim. It is not a cryptographic attestation, a test result signed by the machine, or evidence that the tests ran. Don't ever disable CI on `main`.

## Install

Setup takes two project changes: add the gate to the GitHub Actions workflow, then add instructions to `AGENTS.md`.

```markdown
## Local CI Claims

- Install `already-tested` if needed using the [local CLI instructions](https://github.com/dblock/already-tested#local-cli).
- Run the complete `./script/ci` check in the job's OS, CPU, and toolchain environment.
- Commit the tested files and leave the tracked working tree clean.
- Run `already-tested claim --workflow .github/workflows/test.yml --check test-linux --command './script/ci' --environment '<actual OS, CPU, and toolchain versions>'`.
- Paste the entire output into the PR description, preserving its hidden claim.
- After tracked source or workflow changes, retest, commit, and replace the claim.
- Never claim checks you did not run or other environments; omit the claim and let CI run instead.
```

With this, an AI agent can install the local CLI if needed, run the checks, and add its claim to the pull request. The tool is written in Rust and the CLI ships as prebuilt native binaries; its installer selects and verifies the archive for the agent's OS and CPU. The README includes macOS/Linux and PowerShell installation instructions.

In your GHA workflows, put the gate immediately after checkout and condition every setup, dependency-install, and test step you want to skip. This is the Linux example from the [current README](https://github.com/dblock/already-tested#github-actions):

```yaml
name: Test
on:
  push:
  pull_request:
    types: [opened, synchronize, reopened, edited]
permissions:
  contents: read
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7.0.1
        with:
          fetch-depth: 2
          persist-credentials: false
      - uses: dblock/already-tested@v0.1.0
        id: tested
        with:
          check: test-linux
      - name: Run Tests
        if: steps.tested.outputs.skip != 'true'
        run: ./script/ci
```

## See It

I used the released `0.1.0` CLI in [already-tested PR #8](https://github.com/dblock/already-tested/pull/8). The four CI jobs went from a total of 3m58s to 29s, an improvement of 87.8%. The rest of CI still did useful work. Test jobs on Ubuntu and Windows ran, the other five package targets ran, and all three Coverage jobs ran on macOS, Ubuntu, and Windows.
