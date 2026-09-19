#!/usr/bin/env ruby
# frozen_string_literal: true

# Renders clean Markdown versions of every page for AI agents by
# converting the final, fully-rendered Jekyll HTML output (all Liquid
# tags resolved, all URLs absolute) back to Markdown, instead of copying
# raw source files (which may still contain unresolved Liquid tags and
# inline HTML).
#
# Any HTML page whose layout wraps its content in a #markdown-content
# element gets a sibling .md file, e.g.:
#   _site/2026/01/15/some-post.html -> _site/2026/01/15/some-post.md
#   _site/about/index.html          -> _site/about.md
#   _site/tags/ruby/index.html      -> _site/tags/ruby.md
#   _site/index.html                -> _site/index.md
#
# Pages that already have their own hand-authored .md (e.g. tags.md,
# posts.md, generated directly by Jekyll from a dedicated Liquid
# template) are left untouched.

require 'nokogiri'
require 'reverse_markdown'
require 'fileutils'

ReverseMarkdown.config do |config|
  config.unknown_tags = :bypass
  config.github_flavored = true
end

SITE_DIR = '_site'

def html_to_markdown(html_path)
  doc = Nokogiri::HTML(File.read(html_path))
  content = doc.at_css('#markdown-content')
  return nil unless content

  content.css('script').remove
  ReverseMarkdown.convert(content.inner_html, unknown_tags: :bypass, github_flavored: true).strip + "\n"
end

def markdown_path_for(html_path)
  rel = html_path.delete_prefix("#{SITE_DIR}/")
  if File.basename(rel) == 'index.html'
    dir = File.dirname(rel)
    md_rel = dir == '.' ? 'index.md' : "#{dir}.md"
  else
    md_rel = rel.sub(/\.html\z/, '.md')
  end
  File.join(SITE_DIR, md_rel)
end

Dir.glob(File.join(SITE_DIR, '**', '*.html')).each do |html_path|
  md_path = markdown_path_for(html_path)
  next if File.exist?(md_path) # don't clobber hand-authored .md pages (tags.md, posts.md, etc.)

  markdown = html_to_markdown(html_path)
  next unless markdown

  FileUtils.mkdir_p(File.dirname(md_path))
  File.write(md_path, markdown)
  puts "Rendered #{html_path} -> #{md_path}"
end
