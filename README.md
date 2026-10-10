![](images/blog.gif)

This is my personal tech blog, see it at [code.dblock.org](https://code.dblock.org).

See a typo or want to contribute content? See [CONTRIBUTING](CONTRIBUTING.md).

The site builds with Jekyll 4 and explicitly declared plugins in GitHub Actions, rather than GitHub Pages' bundled Jekyll runtime. Run `bundle install`, then `bundle exec jekyll serve` locally or `bundle exec jekyll build --profile` to measure build time. Stylesheets retain the LibSass-based converter 2.x; migrating the theme to Dart Sass is a separate change.

Content is licensed under the Creative Commons Attribution 4.0 International License, see [LICENSE](LICENSE.md).

## Topics

Tags remain curated in post front matter, but topic pages and counts are generated automatically on every build. Browse `/tags/` to search by topic name or description and sort alphabetically, by post count, or by latest post. Topic pages show dated posts and excerpts; `/tags.md` provides a Markdown index.

Optional entries in `_data/topics.yml` define a topic's `title`, `description`, and `aliases`. For example, `open source` redirects to `open-source`, and both tags contribute to the same deduplicated post list. Existing tag paths are preserved, including names containing spaces. New tags work without registry entries or a minimum post count. No network calls or automatic classification occur during generation.
