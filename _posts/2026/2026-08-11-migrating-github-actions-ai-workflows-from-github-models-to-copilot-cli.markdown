---
layout: post
title: "Migrating GitHub Actions AI Workflows from GitHub Models to Copilot CLI"
date: 2026-08-11
tags: [ai, github-actions, ruby, ci]
comments: true
---

GitHub Models was [retired on July 30, 2026](https://github.blog/changelog/). If you had a GitHub Actions workflow using `actions/ai-inference` to call GitHub Models, it's now broken, with the endpoint returning `410 GitHub Models is temporarily unavailable as part of a scheduled retirement brownout`, except it's not temporary at all. Here's how I found and fixed this in [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client) and [slack-api-ref](https://github.com/slack-ruby/slack-api-ref), two open source Ruby gems I maintain that scrape and vendor Slack's API reference.

### The Setup

Both repos run a scheduled workflow that scrapes Slack's API docs, regenerates code, and opens a pull request with the diff. I recently added a step that asks an LLM to summarize the diff into a human-readable commit message and CHANGELOG entries, using [`actions/ai-inference`](https://github.com/actions/ai-inference) against GitHub Models, GitHub's now-defunct free inference proxy.

```yaml
- name: Generate commit message with AI
  id: ai
  uses: actions/ai-inference@v1
  with:
    prompt-file: ./.github/prompts/commit-message.prompt.yml
    file_input: |
      diff_stat: /tmp/diff_stat.txt
      diff: /tmp/diff.txt
```

This worked fine for a couple of weeks. Then the scheduled run failed with the 410 error above. A little digging confirmed GitHub Models isn't coming back, brownouts on July 16 and 23 were rehearsals for a permanent shutdown.

### The Fix Isn't a Version Bump, It's a Rewrite

The `actions/ai-inference@v1` tag is a moving pointer, so I assumed bumping it, or just re-running, would pick up whatever GitHub shipped as a replacement. It didn't; `v1` still resolves to the same GitHub-Models-only code it always did. The actual replacement is a new major version, `v3` (published July 29, 2026, a day before the models retired), which drops GitHub Models entirely and speaks exclusively to [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli).

```diff
- uses: actions/ai-inference@v1
+ uses: actions/ai-inference@v3
  with:
    prompt-file: ./.github/prompts/commit-message.prompt.yml
+   model: ''
    file_input: |
      diff_stat: /tmp/diff_stat.txt
      diff: /tmp/diff.txt
  env:
+   COPILOT_GITHUB_TOKEN: ${{ secrets.COPILOT_PAT }}
```

A few things changed under the hood.

* `responseFormat: json_schema` and `jsonSchema` inputs are gone. There's no structured output enforcement any more, you ask for JSON in the prompt text and parse the response defensively.
* Auth is via `COPILOT_GITHUB_TOKEN`, not the old `token`/`github.token` input.
* `model` now expects a Copilot CLI model name (`gpt-4.1`, `claude-sonnet-4.5`), not a GitHub Models catalog id (`openai/gpt-4o-mini`). Some of those model names aren't actually available depending on your account's Copilot plan, more below.
* It needs Copilot CLI installed and authenticated on the runner. The action doesn't bundle it.
* The `permissions: models: read` block is no longer needed.

I updated both workflows to install Copilot CLI via npm and swapped the JSON schema parsing for a defensive `grep -v '^```' | jq` pipeline, since the model occasionally still wraps its JSON in markdown fences despite being told not to.

```yaml
- name: Set up Node
  uses: actions/setup-node@v6
- name: Install Copilot CLI
  run: npm install -g @github/copilot
```

```yaml
entries="$(grep -v '^```' "${{ steps.ai.outputs.response-file }}" 2>/dev/null | jq -r '.entries[]? // empty' 2>/dev/null)"
```

### Getting a Token

Copilot CLI in Actions needs a token with the "Copilot Requests" permission. There are two paths.

If your org has a paid Copilot Business/Enterprise plan, you can enable "Allow use of Copilot CLI billed to the organization" and grant the workflow the `copilot-requests: write` permission. No secret needed, the built-in `GITHUB_TOKEN` just works. This is the [GitHub-recommended path](https://github.blog/changelog/2026-07-02-copilot-cli-no-longer-needs-a-personal-access-token-in-github-actions/), but `slack-ruby` is a free org, so it's not an option here (clicking "Enable Copilot" just redirects to the org's billing settings).

The fallback is a personal fine-grained PAT with the "Copilot Requests" account permission, created at [github.com/settings/personal-access-tokens/new](https://github.com/settings/personal-access-tokens/new), stored as a repo (or org) secret, and passed as `COPILOT_GITHUB_TOKEN`. Two gotchas cost me time here.

* "Copilot Requests" only shows up when the token's "Resource owner" is your personal account, not an org. It's an account-level permission because Copilot licenses are per-user, not per-org.
* It only offers "Read" access, no "Read and write". That's fine, read is all the Copilot CLI request permission needs.

### Testing Before Merging

Both workflows have a `github.repository == 'slack-ruby/...'` guard so they don't accidentally run on forks, and I'd rather not relax that permanently just to test. Instead, I pushed a disposable branch to my own fork, temporarily overrode the guard (`if: true`) and added a throwaway step that touches a file to force a non-empty diff (since the real scraping step usually finds nothing new to test with), then dispatched the workflow manually with `gh workflow run`.

```bash
gh workflow enable "Update API" --repo dblock/slack-ruby-client
gh workflow run "Update API" --repo dblock/slack-ruby-client --ref test-copilot-cli
gh run watch <run-id> --repo dblock/slack-ruby-client --exit-status
```

The first run failed with `No authentication information found`, because the `COPILOT_PAT` org secret set on `slack-ruby` isn't visible to my personal fork. Setting the same secret directly on the fork repo got past auth, and surfaced the next problem: `Error: Model "gpt-4.1" from --model flag is not available.` The README uses `gpt-4.1` as an example default model name, but it's not enabled on my account's plan. Passing an explicit empty string, `model: ''`, tells the CLI to just use its own default instead of the action's hardcoded one, and that worked.

I deleted the throwaway test branches once both workflows produced a clean AI-generated response, force-pushed the real fixes onto the pull requests, and squashed the exploratory commits into one.

### Takeaways

* A moving major version tag (`@v1`) isn't a promise of forward compatibility, check what it actually resolves to before assuming a rewrite got picked up automatically.
* When a vendor retires a whole product (GitHub Models), don't expect the drop-in replacement to behave the same way. Read the new action's `action.yml` and README line by line.
* Free and open source organizations may simply not have access to features that require a paid plan (Copilot Business), plan for the personal-PAT fallback from the start.
* Testing GitHub Actions changes on your own fork, with a temporarily relaxed repo guard and a forced diff, is a lot faster than merging and hoping.
