---
layout: post
title: "Releases as Code"
date: 2026-11-12
tags: [open-source, testing, github-actions]
---
A release needs to be reliable, which means it needs to be testable.

A typical release selects a version, updates a changelog, builds an artifact, creates a commit and a tag, publishes the package, creates a GitHub Release, and often prepares the next development version. Projects add their own steps, such as updating version references in documentation, and these steps need to agree on what was released.

If one breaks, the release fails halfway through, leaving a published package without a matching tag or a development version that wasn't updated. You can't always undo a published package and start over.

Test your release code.

## Releases Are Software

I've spent plenty of time maintaining release instructions, shell scripts, and GitHub Actions YAML. They automate the work, but the interesting logic tends to be spread across commands that are hard to exercise without actually making a release.

I wanted to treat a release workflow like the rest of the project: write it in code, customize it in code, and test the behavior that matters.

This idea has become a family of libraries: [npm-package-release](https://github.com/dblock/npm-package-release), [ruby-gem-release](https://github.com/dblock/ruby-gem-release), and [rust-crate-release](https://github.com/dblock/rust-crate-release). Each brings the workflow into the language of the project it releases.

<a href="https://github.com/dblock/npm-package-release"><img src="/images/posts/2026/2026-11-12-releases-as-code/npm-package-release.png" alt="npm-package-release logo" width="140"></a>
<a href="https://github.com/dblock/ruby-gem-release"><img src="/images/posts/2026/2026-11-12-releases-as-code/ruby-gem-release.png" alt="ruby-gem-release logo" width="140"></a>
<a href="https://github.com/dblock/rust-crate-release"><img src="/images/posts/2026/2026-11-12-releases-as-code/rust-crate-release.png" alt="rust-crate-release logo" width="140"></a>

For example, a project's README on the default branch may describe features that haven't been released yet. [Grape's README](https://github.com/ruby-grape/grape#stable-release) identifies the upcoming version and links to the stable release so users don't confuse the two. After a release, I want the development README to say "You're reading the documentation for the next release, v1.2.3." The README at the release tag should identify the stable version instead.

I could do this with a shell script that searches and replaces text, then hope it still works the next time I release. Instead, I can write the release logic in the project's language and test it.

## Updating the README

These examples assume a `## Release Status` section in `README.md`. Each replaces that section during release preparation and again when preparing the next development iteration. Both edits are included in the corresponding commits; they don't change the rest of the README.

### JavaScript

With [npm-package-release](https://github.com/dblock/npm-package-release), export a workflow from `npr.config.js`:

```js
import { LifecycleHooks, MarkdownSection, ReleaseWorkflow } from "npm-package-release";

class UpdateReadme {
  id = "update-readme";

  async run({ context, stage }) {
    const release = stage === "next" ? "next" : "stable";
    await new MarkdownSection("README.md", "## Release Status").replace(
      `You're reading the documentation for the ${release} release, v${context.version}.`,
      { cwd: context.cwd },
    );
  }
}

export function createReleaseWorkflow(services = {}) {
  return new ReleaseWorkflow({
    hooks: new LifecycleHooks().after("prepare", new UpdateReadme()).after("next", new UpdateReadme()),
    ...services,
  });
}

export default createReleaseWorkflow();
```

Use that same builder with the [local test services](https://github.com/dblock/npm-package-release/blob/v0.1.1/docs/testing.md). Here `project` is a `ReleaseTestProject` containing the committed package and README:

```js
import assert from "node:assert/strict";
import { createReleaseWorkflow } from "./npr.config.js";

const workflow = createReleaseWorkflow(project.services);
await workflow.run({ ...project.options, version: "1.2.2" });
assert.ok((await project.remoteFile("v1.2.2", "README.md")).includes("stable release, v1.2.2."));
assert.ok((await project.remoteFile("master", "README.md")).includes("next release, v1.2.3."));
```

### Ruby

With [ruby-gem-release](https://github.com/dblock/ruby-gem-release), add these hooks to the configured `workflow` before calling `workflow.install_tasks`:

```ruby
require 'ruby-gem-release/markdown/section'

section = RubyGemRelease::Markdown::Section.new(path: 'README.md', heading: '## Release Status')
workflow.after(:prepare_release) do |ctx|
  section.replace!("You're reading the documentation for the stable release, v#{ctx.release.version}.")
end
workflow.after(:prepare_next) do |ctx|
  section.replace!("You're reading the documentation for the next release, v#{ctx.release.next_version}.")
end
```

Given a [release test fixture](https://github.com/dblock/ruby-gem-release/blob/v0.6.0/docs/testing.md) containing the project files and its real workflow builder, test the tag and the next development commit:

```ruby
project.configure_workflow(require: 'release_workflow', builder: 'ProjectReleaseWorkflow.build')
project.commit!
project.release!(version: '1.2.2')

expect(project.remote_file('v1.2.2', 'README.md')).to include('stable release, v1.2.2.')
expect(project.remote_file('master', 'README.md')).to include('next release, v1.2.3.')
```

### Rust

With [rust-crate-release](https://github.com/dblock/rust-crate-release), register typed hooks in a [project runner](https://github.com/dblock/rust-crate-release/blob/master/docs/cli.md#project-runners). The next-development hook does nothing when that phase is disabled:

```rust
use std::path::{Path, PathBuf};
use rust_crate_release::{
    Result,
    engine::{Analyzed, Edited, Hosted, NextEdited, ReleaseWorkflow},
    execution::ExecutionContext,
    hooks::LifecycleHook,
    markdown::MarkdownSection,
};

struct UpdateReadme(PathBuf);

fn update_readme(root: &Path, release: &str, version: impl std::fmt::Display) -> Result {
    MarkdownSection::new("## Release Status")?.replace_file(
        &root.join("README.md"),
        &format!("You're reading the documentation for the {release} release, v{version}."),
    )
}

impl LifecycleHook<Analyzed, Edited> for UpdateReadme {
    fn id(&self) -> &str { "release-readme" }
    fn after(&self, output: &Edited, _: &ExecutionContext) -> Result {
        update_readme(&self.0, "stable", output.release().version())
    }
}

impl LifecycleHook<Hosted, NextEdited> for UpdateReadme {
    fn id(&self) -> &str { "next-readme" }
    fn after(&self, output: &NextEdited, _: &ExecutionContext) -> Result {
        if let Some(version) = output.next_version() {
            update_readme(&self.0, "next", version)?;
        }
        Ok(())
    }
}

fn add_readme_hooks(workflow: &mut ReleaseWorkflow) {
    let root = workflow.components.package.root().to_path_buf();
    workflow.hooks.prepare = workflow.hooks.prepare.with(UpdateReadme(root.clone()));
    workflow.hooks.next = workflow.hooks.next.with(UpdateReadme(root));
}
```

Use the same `add_readme_hooks` function with a [release fixture](https://github.com/dblock/rust-crate-release/blob/master/docs/releases.md#test-a-consumer-release) containing the project files:

```rust
fixture.configure_workflow(|workflow| {
    add_readme_hooks(workflow);
    Ok(())
});
fixture.release(Some("1.2.2"))?;
let readme = Path::new("README.md");
assert!(String::from_utf8_lossy(&fixture.remote_file("v1.2.2", readme)?)
    .contains("stable release, v1.2.2."));
assert!(String::from_utf8_lossy(&fixture.remote_file("master", readme)?)
    .contains("next release, v1.2.3."));
```

## Adoption

These libraries started as release code in individual projects. As I found myself solving the same release problems again, I extracted the common workflow into Ruby, JavaScript, and Rust libraries, then replaced the project-specific code with those shared implementations.

Across the release-related JavaScript and Ruby files changed in the adoptions of [eslint-plugin-markdown-preferences-paragraph#19](https://github.com/dblock/eslint-plugin-markdown-preferences-paragraph/pull/19), [eslint-plugin-prose-spellcheck#11](https://github.com/dblock/eslint-plugin-prose-spellcheck/pull/11), [Hashie#653](https://github.com/hashie/hashie/pull/653), and [danger-pr-comment#15](https://github.com/danger/danger-pr-comment/pull/15), the code shrank by 66%.

## Projects Adopting "Releases as Code"

In addition to these projects using themselves to make their own releases, other projects are adopting this approach:

- [ruby-link-checker](https://github.com/dblock/ruby-link-checker/blob/main/.github/workflows/release.yml), [Hashie](https://github.com/hashie/hashie/blob/master/.github/workflows/release.yml), and [danger-pr-comment](https://github.com/danger/danger-pr-comment/blob/main/.github/workflows/release.yml) use ruby-gem-release.
- [eslint-plugin-markdown-preferences-paragraph](https://github.com/dblock/eslint-plugin-markdown-preferences-paragraph) and [eslint-plugin-prose-spellcheck](https://github.com/dblock/eslint-plugin-prose-spellcheck) use npm-package-release.
- [excalc-rs](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml) and [already-tested](https://github.com/dblock/already-tested/blob/master/.github/workflows/release.yml) use rust-crate-release.
