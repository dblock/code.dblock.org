---
layout: post
title: "How to Distribute a Rust App with Cargo, Homebrew, MSI, and WinGet"
date: 2026-11-04
tags: [rust, open-source]
---

I recently [ported my 1996 Pascal/Delphi calculator to Rust](/2026/09/24/porting-my-1996-pascal-calculator-to-rust.html). The result is [excalc](https://github.com/dblock/excalc-rs), a cross-platform command-line application and MCP server.

Rust makes it easy to compile an application on every platform. Distributing it via [crates.io](https://crates.io), MSI, Homebrew or WinGet needed more work. Paste this cookbook into your favorite AI prompt to get it done.

We trigger a distribution from GitHub Releases: a Git tag identifies the new version, CI publishes the crate from that tag, builds portable archives and an MSI from that tag, and attaches everything to the release. Homebrew downloads the tagged source archive. WinGet points at the released MSI.

## Prepare the Rust Package

Start with complete package metadata in [`Cargo.toml`](https://github.com/dblock/excalc-rs/blob/master/Cargo.toml).

```toml
[package]
name = "excalc"
version = "0.3.0"
edition = "2021"
authors = ["Daniel Doubrovkine and contributors"]
description = "An expression calculator CLI tool and MCP server built for AI coding agents to outsource arithmetic."
license = "MIT"
repository = "https://github.com/dblock/excalc-rs"
default-run = "excalc"
```

Add every binary you want Cargo and the installer to build.

```toml
[[bin]]
name = "excalc"
path = "src/main.rs"

[[bin]]
name = "calc"
path = "src/main.rs"

[[bin]]
name = "excalc-mcp"
path = "src/bin/excalc-mcp.rs"
required-features = ["mcp"]
```

Note the double brackets in `[[bin]]`. TOML calls this an [array of tables](https://toml.io/en/v1.0.0#array-of-tables), where each `[[bin]]` block adds another executable with its own name and source path.

In excalc, `mcp` is a default feature. CLI-only users can opt out with `cargo install excalc --no-default-features`; release builds retain the default features.

Add a [`LICENSE`](https://github.com/dblock/excalc-rs/blob/master/LICENSE), [`README.md`](https://github.com/dblock/excalc-rs/blob/master/README.md), and [`CHANGELOG.md`](https://github.com/dblock/excalc-rs/blob/master/CHANGELOG.md), then verify what will be uploaded.

```bash
cargo fmt --all -- --check
cargo clippy --all-targets --all-features -- -D warnings
cargo test --all-features
cargo publish --dry-run
```

The dry run packages the crate and compiles the packaged copy.

## Publish to crates.io

For excalc, I published the first version manually, then configured a trusted CI publisher for subsequent releases.

1. Create a crates.io account and verify its email address.
2. Create an API token in crates.io account settings.
3. Run `cargo login`; modern Cargo reads the token from standard input.
4. Publish the first version.

```bash
cargo publish
```

For subsequent releases, use [crates.io Trusted Publishing](https://crates.io/docs/trusted-publishing) instead of storing a long-lived `CARGO_REGISTRY_TOKEN` in GitHub.

Open the crate's **Settings → Trusted Publishing** page and add a GitHub Actions publisher with:

- Owner: your GitHub organization or username
- Repository: your repository name
- Workflow: [`release.yml`](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml)
- Environment: leave blank unless the workflow uses a GitHub environment

Add this job to [`.github/workflows/release.yml`](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml).

{% raw %}

```yaml
name: Release

on:
  release:
    types: [published]

env:
  RELEASE_TAG: ${{ github.event.release.tag_name }}

jobs:
  publish:
    name: Publish crate
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ env.RELEASE_TAG }}
      - uses: dtolnay/rust-toolchain@stable
      - uses: rust-lang/crates-io-auth-action@v1
        id: auth
      - name: Publish to crates.io
        run: cargo publish
        env:
          CARGO_REGISTRY_TOKEN: ${{ steps.auth.outputs.token }}
```

{% endraw %}

The action exchanges GitHub's OIDC identity for a short-lived crates.io credential. You do not need a GitHub secret.

Users can now install the application on any platform with a Rust toolchain.

```bash
cargo install excalc
```

## Build Portable Archives

Not everyone has Rust installed or wants to compile your application. Build portable archives containing the binaries, README, CHANGELOG, and LICENSE for macOS on Apple Silicon (`aarch64-apple-darwin`), macOS on Intel (`x86_64-apple-darwin`), Linux ARM64 statically linked with musl (`aarch64-unknown-linux-musl`), Linux x86-64 statically linked with musl (`x86_64-unknown-linux-musl`), and Windows x86-64 (`x86_64-pc-windows-msvc`).

I first tried [cargo-dist](https://github.com/axodotdev/cargo-dist). It generated a complete release system with planning, artifact staging, manifests, release creation, and announcement jobs. This is useful if you want cargo-dist to own your entire release process, add shell and PowerShell installers, support `cargo-binstall`, produce provenance, or manage more package formats.

But it was too much for excalc. I already had working crates.io Trusted Publishing, MSI creation, and GitHub Release workflows. I gave up on it and used a plain matrix job.

{% raw %}

```yaml
archives:
  name: Archive (${{ matrix.target }})
  runs-on: ${{ matrix.runner }}
  permissions:
    contents: write
  strategy:
    fail-fast: false
    matrix:
      include:
        - target: aarch64-apple-darwin
          runner: macos-14
          format: tar
        - target: x86_64-apple-darwin
          runner: macos-15-intel
          format: tar
        - target: aarch64-unknown-linux-musl
          runner: ubuntu-22.04-arm
          format: tar
        - target: x86_64-unknown-linux-musl
          runner: ubuntu-22.04
          format: tar
        - target: x86_64-pc-windows-msvc
          runner: windows-2022
          format: zip
  steps:
    - uses: actions/checkout@v4
      with:
        ref: ${{ env.RELEASE_TAG }}
    - uses: dtolnay/rust-toolchain@stable
      with:
        targets: ${{ matrix.target }}
    - uses: Swatinem/rust-cache@v2
      with:
        key: release-${{ matrix.target }}
    - name: Install musl tools
      if: contains(matrix.target, 'linux-musl')
      run: sudo apt-get update && sudo apt-get install -y musl-tools
    - name: Build binaries
      run: cargo build --release --target "${{ matrix.target }}" --bin excalc --bin calc --bin excalc-mcp
```

{% endraw %}

Package Unix builds with `tar` and Windows with `Compress-Archive`. Use the full version and Rust target triple in each filename, for example `excalc-0.3.0-aarch64-unknown-linux-musl.tar.gz`. Generate a SHA-256 file next to every archive.

{% raw %}

```bash
version="${RELEASE_TAG#v}"
name="excalc-${version}-${{ matrix.target }}"
mkdir -p "target/release-archives/${name}"
cp "target/${{ matrix.target }}/release/excalc" "target/${{ matrix.target }}/release/calc" "target/${{ matrix.target }}/release/excalc-mcp" README.md CHANGELOG.md LICENSE "target/release-archives/${name}/"
tar -C target/release-archives -czf "target/release-archives/${name}.tar.gz" "${name}"
cd target/release-archives
shasum -a 256 "${name}.tar.gz" > "${name}.tar.gz.sha256"
```

{% endraw %}

Upload the archive and checksum to the existing release.

{% raw %}

```yaml
- name: Upload archive
  env:
    GH_TOKEN: ${{ github.token }}
  run: gh release upload "$RELEASE_TAG" target/release-archives/*.tar.gz target/release-archives/*.sha256 --clobber
```

{% endraw %}

The resulting portable archive contains the three user-facing binaries and the documentation files. The Windows-only MSI setup helper remains in the MSI and is not included in the ZIP.

The excalc macOS binaries are not signed or notarized, so Gatekeeper rejects them after download. After verifying the archive's SHA-256 checksum, remove the quarantine attribute from each extracted binary before running it:

```bash
xattr -d com.apple.quarantine ./calc
xattr -d com.apple.quarantine ./excalc
xattr -d com.apple.quarantine ./excalc-mcp
```

This is not a substitute for signing, just a temporary distribution limitation. A production-quality macOS archive should sign every executable with a Developer ID Application certificate and submit the archive to Apple's notarization service in CI. Maybe some day.

## Build a Windows MSI

Install [cargo-wix](https://github.com/volks73/cargo-wix) and initialize an installer.

```bash
cargo install cargo-wix --version 0.3.9 --locked
cargo wix init
```

This creates [`wix/main.wxs`](https://github.com/dblock/excalc-rs/blob/master/wix/main.wxs). Edit it to set the product name, manufacturer, description, installation directory, and binaries. Keep `UpgradeCode` stable across releases so Windows knows that a newer MSI upgrades the installed application.

The excalc installer includes `excalc.exe`, `calc.exe`, and `excalc-mcp.exe`.

```xml
<Component Id='ExcalcBinary' Guid='*'>
    <File
        Id='ExcalcExe'
        Name='excalc.exe'
        DiskId='1'
        Source='$(var.CargoTargetBinDir)\excalc.exe'
        KeyPath='yes'/>
</Component>
```

Build the MSI locally on Windows.

```powershell
cargo wix --nocapture
```

The installer will appear under `target/wix/`.

Build it in CI on every push and pull request so installer problems are found before a release.

{% raw %}

```yaml
name: MSI

on:
  push:
    branches: [master]
  pull_request:

jobs:
  msi:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      - name: Cache cargo-wix
        id: cache-cargo-wix
        uses: actions/cache@v4
        with:
          path: ~/.cargo/bin/cargo-wix.exe
          key: cargo-wix-0.3.9-${{ runner.os }}
      - name: Install cargo-wix
        if: steps.cache-cargo-wix.outputs.cache-hit != 'true'
        run: cargo install cargo-wix --version 0.3.9 --locked
      - name: Build MSI
        run: cargo wix --nocapture
      - uses: actions/upload-artifact@v4
        with:
          name: excalc-msi
          path: target/wix/*.msi
```

{% endraw %}

Add another job to [`release.yml`](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml) to build the MSI from the release tag and attach it to the GitHub release.

{% raw %}

```yaml
msi:
  name: Attach MSI installer to release
  runs-on: windows-latest
  permissions:
    contents: write
  steps:
    - uses: actions/checkout@v4
      with:
        ref: ${{ env.RELEASE_TAG }}
    - uses: dtolnay/rust-toolchain@stable
    - uses: Swatinem/rust-cache@v2
    - name: Cache cargo-wix
      id: cache-cargo-wix
      uses: actions/cache@v4
      with:
        path: ~/.cargo/bin/cargo-wix.exe
        key: cargo-wix-0.3.9-${{ runner.os }}
    - name: Install cargo-wix
      if: steps.cache-cargo-wix.outputs.cache-hit != 'true'
      run: cargo install cargo-wix --version 0.3.9 --locked
    - name: Build MSI
      run: cargo wix --nocapture
    - name: Upload MSI
      env:
        GH_TOKEN: ${{ github.token }}
      run: gh release upload "$env:RELEASE_TAG" target/wix/*.msi --clobber
```

{% endraw %}

The `contents: write` permission is required to upload a release asset. Cache the compiled `cargo-wix.exe`; installing cargo-wix from source took approximately 75 seconds in excalc's first CI run.

## Add a Homebrew Formula

Create [`Formula/excalc.rb`](https://github.com/dblock/excalc-rs/blob/master/Formula/excalc.rb) in the same repository.

```ruby
class Excalc < Formula
  desc "Expression calculator CLI tool and MCP server for AI coding agents"
  homepage "https://github.com/dblock/excalc-rs"
  url "https://github.com/dblock/excalc-rs/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "f2258c802947d6f55043c364f7c587541389ae10a68968af2c68f1d84258622f"
  license "MIT"
  head "https://github.com/dblock/excalc-rs.git", branch: "master"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_equal "4", shell_output("#{bin}/excalc '2 + 2'").strip
    assert_equal "4", shell_output("#{bin}/calc '2 + 2'").strip
    assert_path_exists bin/"excalc-mcp"
  end
end
```

This formula builds the tagged source with `cargo install`. The tests verify all three installed binaries, not just the primary command.

After creating a release tag, its archive URL and checksum must be updated in the formula. Automate this in the release workflow rather than doing it by hand.

Wait until crates.io publishing, portable archives, and the MSI have all succeeded. Then check out `master`, download the tagged source archive, compute its SHA-256, replace the formula's URL and checksum, and validate the formula before committing it.

The [complete release workflow](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml) contains the checkout, checksum replacement, validation, and commit steps. Its Homebrew job depends on successful publishing and artifact jobs, and uses `contents: write` with the built-in `GITHUB_TOKEN`; no additional credential is required. Commits made with that token do not trigger another set of workflows, so audit, install, and test the formula before pushing. A concurrency group prevents two releases from updating the formula simultaneously.

Also validate the formula on ordinary changes in [`.github/workflows/homebrew.yml`](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/homebrew.yml).

Users install from the repository-backed tap with:

```bash
brew tap dblock/excalc-rs https://github.com/dblock/excalc-rs
brew trust --formula dblock/excalc-rs/excalc
brew install excalc
```

Homebrew 6 requires users to trust third-party taps or individual formulae. Include the `brew trust` command in your installation instructions.

## Submit the MSI to WinGet

WinGet needs a stable installer URL, so publish the GitHub release and wait for the MSI workflow to attach the asset first.

For excalc `0.3.0`, the installer URL is:

```text
https://github.com/dblock/excalc-rs/releases/download/v0.3.0/excalc-0.3.0-x86_64.msi
```

Install Microsoft's [WinGetCreate](https://github.com/microsoft/winget-create) tool on Windows.

```powershell
winget install Microsoft.WingetCreate
```

Create the initial manifests from the MSI URL.

```powershell
wingetcreate new https://github.com/dblock/excalc-rs/releases/download/v0.3.0/excalc-0.3.0-x86_64.msi
```

WinGetCreate prompts for package metadata and can submit a pull request to [microsoft/winget-pkgs](https://github.com/microsoft/winget-pkgs). The resulting package consists of version, installer, and locale manifests. Our accepted manifests were ultimately generated with [Komac](https://github.com/russellbanks/Komac). An excerpt from the accepted installer manifest:

```yaml
PackageIdentifier: Vestris.Excalc
PackageVersion: 0.3.0
InstallerType: wix
Scope: machine
UpgradeBehavior: install
Commands:
  - calc
  - excalc
  - excalc-mcp
Installers:
  - Architecture: x64
    InstallerUrl: https://github.com/dblock/excalc-rs/releases/download/v0.3.0/excalc-0.3.0-x86_64.msi
    InstallerSha256: 61D8E7538EADA6D1A4FA1B65C23F27EABD4588471D0EAD6A9FBB9A5BD79B47DD
ManifestType: installer
ManifestVersion: 1.28.0
```

Local manifest installation requires [local manifests to be enabled](https://learn.microsoft.com/en-us/windows/package-manager/winget/install#local-manifests). Then, validate and test the complete manifest directory:

```powershell
winget settings --enable LocalManifestFiles
winget validate --manifest manifests/v/Vestris/Excalc/0.3.0
winget install --manifest manifests/v/Vestris/Excalc/0.3.0
```

The initial submission, [microsoft/winget-pkgs#441253](https://github.com/microsoft/winget-pkgs/pull/441253), took 39 days to work its way through the human review queue and needed fixes on my side. The submission also required Microsoft's Contributor License Agreement and moderator approval.

After the publish pipeline succeeded, I verified installation in Windows PowerShell:

```powershell
winget install --id Vestris.Excalc --exact
```

WinGet found `0.3.0`, downloaded the MSI, verified its hash, and installed it successfully. Open a new terminal to pick up the updated `PATH`, then:

```powershell
excalc 2+2
# 4
```

For a subsequent version, generate an update using that version's MSI URL. For example, if the next release is `0.4.0`:

```powershell
wingetcreate update Vestris.Excalc --version 0.4.0 --urls https://github.com/dblock/excalc-rs/releases/download/v0.4.0/excalc-0.4.0-x86_64.msi
```

That command prepares an update; review and submit the generated manifests. WinGet updates are pull requests to Microsoft's repository, so this channel is asynchronous.

## Automate WinGet Updates

I [added WinGet submission to the release workflow](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml) using [`WinGet Releaser`](https://github.com/vedantmgoyal9/winget-releaser), which runs Komac under the hood. At least one version must already be accepted in `microsoft/winget-pkgs`; the action uses that package as the base for subsequent manifests.

The job waits for successful crate publishing, portable archives, and MSI upload. It runs only for stable published releases, not pre-release versions or manual artifact rebuilds. The submission step selects only the x64 MSI, not the portable ZIP or checksum files:

{% raw %}

```yaml
- name: Submit manifest pull request
  id: winget
  uses: vedantmgoyal9/winget-releaser@b7370d4d152efdce803a26cc6ca9eee58cb2ad54
  with:
    identifier: Vestris.Excalc
    installers-regex: '^excalc-[0-9]+\.[0-9]+\.[0-9]+-x86_64\.msi$'
    release-tag: ${{ env.RELEASE_TAG }}
    token: ${{ secrets.WINGET_TOKEN }}
```

{% endraw %}

The [full release workflow](https://github.com/dblock/excalc-rs/blob/master/.github/workflows/release.yml) includes the dependency checks, a concurrency group, an explicit failure when the token is missing, and a job summary linking to the submitted PR. It keeps previous package versions.

Unlike the Homebrew update in the same repository, this needs a [cross-repository credential with `public_repo` and `workflow` scopes]((https://github.com/settings/tokens/new?description=ExCalc%20WinGet&scopes=public_repo,workflow)) to push to a separate `winget-pkgs` fork and open Microsoft's upstream PR. I created the token and stored it with `gh secret set WINGET_TOKEN --repo dblock/excalc-rs`.

## Cut a Release

Even with all the automation I keep a written release checklist. The excalc version lives in [RELEASING.md](https://github.com/dblock/excalc-rs/blob/master/RELEASING.md).

For every release:

1. Move the contents of `[Unreleased]` in [`CHANGELOG.md`](https://github.com/dblock/excalc-rs/blob/master/CHANGELOG.md) under the new version and date.
2. Update the version in [`Cargo.toml`](https://github.com/dblock/excalc-rs/blob/master/Cargo.toml).
3. Run `cargo build` to regenerate `Cargo.lock`.
4. Run formatting, linting, tests, and `cargo publish --dry-run`.
5. Commit and push, then wait for CI before tagging the release commit.

```bash
git add Cargo.toml Cargo.lock CHANGELOG.md
git commit -m "Release v0.3.0"
git push origin master
```

Once CI passes, tag that exact commit:

```bash
git tag -a v0.3.0 -m "v0.3.0"
git push origin v0.3.0
```

Create the GitHub release.

```bash
gh release create v0.3.0 --title "v0.3.0" --notes-from-tag
```

Wait for the release workflow to publish the crate and attach the portable archives, checksums, and MSI. Confirm it updated, tested, committed, and pushed the Homebrew formula with the new tag and checksum. Follow the automatically submitted WinGet PR through Microsoft's publish pipeline, then verify every channel.

```bash
cargo search excalc --limit 1
gh release view v0.3.0
brew update
brew upgrade dblock/excalc-rs/excalc
winget show Vestris.Excalc
```

The Git tag is the invariant. Cargo publishes it, the MSI is built from it, Homebrew downloads it, and WinGet points at an artifact attached to it.

Do this once, put every validation step in CI, and write down the remaining manual steps. With most steps automated Copilot does a great job making my releases for me, I just tell it "release 0.3.0".
