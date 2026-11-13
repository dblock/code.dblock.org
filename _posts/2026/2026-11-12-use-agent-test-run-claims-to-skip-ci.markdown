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

Setup takes two project changes: add the gate to the GitHub Actions workflow, then add this to `AGENTS.md` or `.github/copilot-instructions.md`:

```markdown
## Local CI Claims

- Install `already-tested` using https://github.com/dblock/already-tested/blob/v0.3.0/docs/cli.md#installation.
- Run `already-tested agent-instructions show` and follow its guidance before generating or updating claims.
```

The agent installs the CLI, reads the instructions bundled with that version, and inspects your CI workflows to find the complete checks and required environments. The guidance covers measured run times, committed source, local verification, and publishing claims in the PR description. Keep project-specific environment exceptions in your own instructions. The tool is written in Rust and ships as prebuilt native binaries; its installer selects and verifies the archive for the agent's OS and CPU.

To keep a versioned copy of the guidance in your repository, have the agent run `already-tested agent-instructions update`. If `.github/copilot-instructions.md` exists, this writes `.github/instructions/already-tested.instructions.md` and adds a reference to the Copilot instructions. Otherwise, it writes `.already-tested/agent-instructions.md` and updates or creates `AGENTS.md`. Handwritten policy stays intact. Review and commit the files; repeat the command when upgrading. See [agent setup and upgrades](https://github.com/dblock/already-tested/blob/v0.3.0/docs/agents.md#adopt-in-a-project).

In your GHA workflows, put the gate immediately after checkout and condition every setup, dependency-install, and test step you want to skip. This is the Linux example from the [v0.3.0 README](https://github.com/dblock/already-tested/blob/v0.3.0/README.md#installation):

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
      - uses: dblock/already-tested@v0.3.0
        id: tested
        with:
          check: test-linux
      - name: Run Tests
        if: steps.tested.outputs.skip != 'true'
        run: ./script/ci
```

## See It

I used the released `0.1.0` CLI in [already-tested PR #8](https://github.com/dblock/already-tested/pull/8). The four CI jobs went from a total of 3m58s to 29s, an improvement of 87.8%. The rest of CI still did useful work. Test jobs on Ubuntu and Windows ran, the other five package targets ran, and all three Coverage jobs ran on macOS, Ubuntu, and Windows.
