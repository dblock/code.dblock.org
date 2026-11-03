# Agents

This is a Jekyll blog deployed via GitHub Pages with a custom GitHub Actions workflow.

When drafting or editing blog posts, follow [VOICE.md](VOICE.md) so new posts match the author's style.

## Branches

The live site is built from the `gh-pages` branch, not `master`. Commit and push changes to `gh-pages`.

## Before Committing

### Generate Tag Pages

Topic pages, counts, post tag links, and `/tags.md` are generated during every Jekyll build by `_plugins/topics.rb`. Do not check in generated tag pages or counts. `bundle exec rake tags` remains a compatibility alias for building the site. Keep editorial tags in post front matter; `_data/topics.yml` optionally defines canonical titles, descriptions and aliases. Alias pages redirect to canonical topics, and alias membership is deduplicated without rewriting posts. Build-time membership follows Jekyll's published/future/draft settings.

Use canonical names from `_data/topics.yml` when editing post tags. Keep previous names as aliases when renaming topics; redirects are generated for every configured alias of a populated topic, even after posts stop using the old name.

### Spelling

A pre-commit hook runs `bundle exec rake precommit`, including `spell:staged` to check staged `.md` and `.markdown` files. Configuration or dictionary changes trigger a full check; CI always checks the full archive. If it fails:

- **Fix a typo**: correct the word in the post.
- **Add a legitimate word** (acronym, proper noun, technical term): add it to `.spellcheck.txt`, one word per line, in alphabetical order.
- **Suppress a word inline**: wrap it in backticks (inline code) to exclude it from spell checking.

Spelling uses `rubocop-spellcheck` with its bundled English dictionary and `.spellcheck.txt`. Run `bundle exec rubocop` for prose, Ruby lint, and spelling, or `bundle exec rake spell:check` for spelling only. Configuration is in `.rubocop.yml`; front matter spelling checks the `title` field.

### Style

A pre-commit hook also runs `bundle exec rake lint`, using released `rubocop-prose` 0.2.x for Markdown and released `rubocop-md` 3.x for Ruby code fences. Dependency versions are pinned in `Gemfile.lock`. Configuration is in `.rubocop.yml`. Run `bundle exec rubocop -a --except Spellcheck/Spelling` for safe autocorrection; review changes to historical examples rather than changing their intended behavior.

Pushes and pull requests check all Markdown, Ruby files, and explicitly Ruby-tagged code fences. Unlabeled code blocks are not guessed to be Ruby. Keep each prose paragraph on one source line (`Prose/MaxLength`, with `Max: false`); intentional Markdown hard breaks and `<br>` boundaries remain supported. A separate workflow checks spelling.

### Downloads

Place new post downloads under `downloads/posts/YYYY-MM-DD-post-slug/`, with descriptive filenames such as `pull-requests.csv`. Link to those paths from the post.

### Images and Screenshots

Optimize all images and screenshots with `pngquant` before adding them to the repo. macOS screenshot filenames contain a narrow no-break space (U+202F) before AM/PM, so use Python to handle them:

```python
import os, subprocess

src = "path/to/screenshot.png"
out = "images/posts/YYYY/YYYY-MM-DD-post-slug/image-name.png"

subprocess.run(
    ["pngquant", "--quality=65-85", "-", "--output", out, "--force"],
    stdin=open(src, "rb")
)
```

Place images under `images/posts/YYYY/YYYY-MM-DD-post-slug/` to match the post's date and slug.
