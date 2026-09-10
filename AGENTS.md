# Agents

This is a Jekyll blog deployed via GitHub Pages with a custom GitHub Actions workflow.

## Branches

The live site is built from the `gh-pages` branch, not `master`. Commit and push changes to `gh-pages`.

## Before Committing

### Generate Tag Pages

After adding or changing tags in a post's front matter, regenerate the tag pages:

```bash
bundle exec rake tags
```

This rewrites `tags/*.md` and `_data/tags.yml` from the tags found across all posts.

### Spelling

A pre-commit hook runs `pyspelling` to check spelling in all `.md` and `.markdown` files. If it fails:

- **Fix a typo**: correct the word in the post.
- **Add a legitimate word** (acronym, proper noun, technical term): add it to `.pyspelling.words`, one word per line, in alphabetical order. For example, `SEO` and `signups` were added this way.
- **Suppress a word inline**: wrap it in backticks (inline code) to exclude it from spell checking.

### Style

A pre-commit hook also runs `markdownlint-cli2` using `.markdownlint.yaml`. Fix any reported issues before committing.

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
