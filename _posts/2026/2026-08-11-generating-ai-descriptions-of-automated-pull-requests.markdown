---
layout: post
title: "Generating AI Descriptions of Automated Pull Requests"
date: 2026-08-11
tags: [ai, github-actions, ruby, ci]
comments: true
---

The [slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client) library, an open source Ruby gem I maintain, runs a [scheduled GitHub Actions workflow](https://github.com/slack-ruby/slack-ruby-client/blob/master/.github/workflows/update_api.yml) that regenerates code from [Slack's API definitions](https://github.com/slack-ruby/slack-api-ref) and opens a pull request with the diff. The commit message and CHANGELOG entry used to be a generic "Update API (2026-08-11)", which told a reviewer nothing about what actually changed. Here's how we taught the workflow to describe its own diffs, using GitHub Copilot CLI, which [open source maintainers can get for free](https://docs.github.com/en/copilot/how-to/copilot-on-github/set-up-copilot/access-copilot-pro-for-free-as-a-teacher-or-open-source-maintainer).

![Generated CHANGELOG entries grouped by PR](/images/posts/2026/2026-08-11-generating-ai-descriptions-of-automated-pull-requests/changelog.png)

### The Idea

The workflow already computes a diff before opening the pull request. Instead of a boilerplate commit message, we pipe that diff through an LLM and ask it to summarize what changed, then use the response as the commit message and PR body.

```yaml
- name: Check for changes
  id: changes
  run: |
    if git diff --quiet; then
      echo "changed=false" >> "$GITHUB_OUTPUT"
    else
      echo "changed=true" >> "$GITHUB_OUTPUT"
    fi
- name: Prepare diff for AI summary
  if: steps.changes.outputs.changed == 'true'
  run: |
    git diff --stat | sed 's/^/      /' > /tmp/diff_stat.txt
    git diff | head -c 20000 | sed 's/^/      /' > /tmp/diff.txt
```

The `sed 's/^/      /'` indent isn't decorative. `actions/ai-inference` substitutes template variables as raw text into a prompt YAML file *before* parsing it, so a multi-line diff starting at column 0 breaks the indentation of the enclosing `content: |-` block scalar. Pre-indenting the file to match keeps the YAML valid no matter what the diff looks like.

### The Prompt File

`actions/ai-inference` supports `.prompt.yml` files, a small convention for keeping the system/user prompt out of the workflow YAML.

```yaml
messages:
  - role: system
    content: |-
      You write CHANGELOG entries describing an automated API update to slack-ruby-client, a
      Ruby gem whose Web API endpoint methods, argument validations, specs, and bin commands
      are code-generated from vendored Slack API method definitions (via a git submodule and
      rake task).

      Given a diffstat and a diff of the regenerated files, respond with ONLY a single JSON
      object (no markdown code fences, no other text) in exactly this shape:
      {"entries": [string, ...]}

      Rules for entries:
      - Each entry is a single short line, imperative mood, no leading bullet/dash and no
        trailing period (the caller adds both).
      - Group related changes together into one entry per notable change or affected method
        group, rather than one entry per file.
      - Focus on developer-visible API surface changes: new/removed/renamed methods, new/
        removed arguments, validation changes.
  - role: user
    content: |-
      {{diff_stat}}
      {{diff}}
```

Asking for a single line per group of changes, rather than per file, matters, a single Slack API update can touch dozens of generated files for one conceptual change (adding an argument to five related methods, say), and nobody wants five identical CHANGELOG lines about it.

### Wiring It into the Workflow

```yaml
- name: Generate changelog entries with AI
  if: steps.changes.outputs.changed == 'true'
  id: ai
  uses: actions/ai-inference@v1
  with:
    prompt-file: ./.github/prompts/changelog-entries.prompt.yml
    file_input: |
      diff_stat: /tmp/diff_stat.txt
      diff: /tmp/diff.txt
- name: Build changelog entries
  id: entries
  run: |
    entries=""
    if [ "${{ steps.changes.outputs.changed }}" = "true" ]; then
      entries="$(grep -v '^```' "${{ steps.ai.outputs.response-file }}" 2>/dev/null | jq -r '.entries[]? // empty' 2>/dev/null)"
    fi
    if [ -z "$entries" ]; then
      entries="Update API (${{ steps.date.outputs.date }})"
    fi
```

Two defensive touches worth calling out. First, the `grep -v '^```'` strips markdown code fences the model sometimes adds despite being told not to, before `jq` tries to parse the JSON. Second, if parsing fails or produces nothing, the workflow falls back to the original generic message rather than failing the whole run.

Once we have the entries, we use them both as the commit message/PR body and to insert one CHANGELOG line per group, all referencing the same (predictable, since GitHub allocates them sequentially) PR number:

```ruby
lines = entries.map do |entry|
  "* [##{pr_number}](#{pr_url}): #{entry} - [@slack-ruby-ci-bot](https://github.com/apps/slack-ruby-ci-bot)."
end.join("\n")
```

### You Can't Use GitHub Models

If you're setting this up today, skip GitHub Models as the backend, it was [retired on July 30, 2026](https://github.blog/changelog/) and `actions/ai-inference` no longer talks to it at any version. The `v1` tag, in particular, doesn't float to the rewrite, it's stuck resolving to the old GitHub-Models-only code, so don't expect a version bump to fix things automatically. The current major version, `v3`, speaks exclusively to [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/copilot-cli) instead, which changes a few things about the setup:

```yaml
- name: Set up Node
  uses: actions/setup-node@v6
- name: Install Copilot CLI
  run: npm install -g @github/copilot
- name: Generate changelog entries with AI
  if: steps.changes.outputs.changed == 'true'
  id: ai
  uses: actions/ai-inference@v3
  with:
    prompt-file: ./.github/prompts/changelog-entries.prompt.yml
    model: ''
    file_input: |
      diff_stat: /tmp/diff_stat.txt
      diff: /tmp/diff.txt
  env:
    COPILOT_GITHUB_TOKEN: ${{ secrets.COPILOT_PAT }}
```

Copilot CLI has to be installed on the runner (the action doesn't bundle it any more), authentication is via `COPILOT_GITHUB_TOKEN` rather than the old `token` input, and `responseFormat`/`jsonSchema` inputs are gone entirely, hence asking for bare JSON in the prompt and parsing it defensively, as above. We also set `model: ''` explicitly; the action's built-in default (`gpt-4.1`) isn't necessarily available on every Copilot plan, and an empty string tells the CLI to fall back to whatever model it has access to.

For the token, if your org has a paid Copilot Business or Enterprise plan, you can enable "Allow use of Copilot CLI billed to the organization" and grant the workflow the `copilot-requests: write` permission, then the built-in `GITHUB_TOKEN` just works, no secret needed. Free organizations (like `slack-ruby`) don't have that option, since [free Copilot access for open source maintainers](https://docs.github.com/en/copilot/how-to/copilot-on-github/set-up-copilot/access-copilot-pro-for-free-as-a-teacher-or-open-source-maintainer) is granted to individual maintainer accounts, not organizations, so the fallback is a personal fine-grained PAT with the "Copilot Requests" account permission, stored as a `COPILOT_PAT` secret.

### Testing Before Merging

Both workflows have a `github.repository == 'slack-ruby/...'` guard so they don't run on forks by accident, which also means we can't just dispatch them there to test. We got around this by pushing a disposable branch to our own fork, temporarily overriding the guard (`if: true`), adding a throwaway step to force a non-empty diff (the real scraping step usually finds nothing new on a given day), and dispatching manually.

```bash
gh workflow enable "Update API" --repo dblock/slack-ruby-client
gh workflow run "Update API" --repo dblock/slack-ruby-client --ref test-copilot-cli
gh run watch <run-id> --repo dblock/slack-ruby-client --exit-status
```

This is how I caught both the missing-token and the unavailable-model issues above, neither of which was obvious from reading the action's README.

### Links

* [#591: Generate AI CHANGELOG entries for automated API update PRs](https://github.com/slack-ruby/slack-ruby-client/pull/591)
* [#592: Fix YAML indentation bug in AI prompt template substitution](https://github.com/slack-ruby/slack-ruby-client/pull/592)
* [#593: Migrate AI CHANGELOG entry generation to Copilot CLI](https://github.com/slack-ruby/slack-ruby-client/pull/593)
* [#594: Include AI-generated changelog entries in the commit message](https://github.com/slack-ruby/slack-ruby-client/pull/594)
* [First successful run on master](https://github.com/slack-ruby/slack-ruby-client/actions/runs/31555479354/job/93986905749)
