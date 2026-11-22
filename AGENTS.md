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

### Links

Links are checked by the jekyll-ruby-link-checker gem, configured under `link_checker` in `_config.yml`; see [CONTRIBUTING.md](CONTRIBUTING.md#link-checker). Links that bot protection blocks are reported as unverified and don't fail the build, so leave those sites checked. When a site answers with an error, such as a 404, for a page that exists, try a header in `link_checker.host_headers` first, and otherwise add its domain to `link_checker.exclude.domains`, rather than removing the link. Keep the gem's commit in the `Gemfile` and in `.github/workflows/link-checker*.yml` the same.

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

### Social Cards

Every post gets a generated 1200×630 social card, so links shared on X, LinkedIn, and elsewhere unfurl as a large card with the post title. [jekyll-og-image](https://github.com/igor-alexandrov/jekyll-og-image) renders the cards with libvips into `images/og/posts/<year>/<post>.png`, with the post title and the first sentence of its excerpt, and sets the post's `image.path`, which `_includes/_open-graph.html` uses. Cards are regenerated when anything on them changes. Do not check in generated cards; `images/og/` is ignored.

- **Override a card**: set `image.feature` in the post's front matter to use one of the post's own images instead. To change only the sentence on the card, set `og_image.description.source` to a front matter field, such as `description`, and add that field.
- **Gem source**: the description comes from [jekyll-og-image#33](https://github.com/igor-alexandrov/jekyll-og-image/pull/33), loaded from the `dblock/description` branch of the fork until it is released; then switch the Gemfile back to the released gem.
- **Change the design**: edit `og_image` in `_config.yml`, or `og_image` in a post's front matter for one post, and look at a few rendered cards, including a long title, before committing.
- **Fonts**: cards use the site's PT Serif and PT Sans Narrow. macOS includes them; CI installs them from `_og/fonts`, see `_og/README.md`.
