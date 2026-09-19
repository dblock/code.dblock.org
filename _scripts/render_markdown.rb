#!/usr/bin/env ruby
# frozen_string_literal: true

# Renders clean Markdown versions of posts and pages for AI agents by
# converting the final, fully-rendered Jekyll HTML output (all Liquid
# tags resolved, all URLs absolute) back to Markdown, instead of copying
# raw source files (which may still contain unresolved Liquid tags and
# inline HTML).

require 'nokogiri'
require 'reverse_markdown'

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

def write_markdown(html_path, md_path)
  markdown = html_to_markdown(html_path)
  return unless markdown

  FileUtils.mkdir_p(File.dirname(md_path))
  File.write(md_path, markdown)
  puts "Rendered #{html_path} -> #{md_path}"
end

require 'fileutils'

# Posts: _posts/YYYY/YYYY-MM-DD-slug.md -> _site/YYYY/MM/DD/slug.html -> _site/YYYY/MM/DD/slug.md
Dir.glob('_posts/**/*.{md,markdown}').each do |file|
  filename = File.basename(file)
  next unless filename =~ /^(\d{4})-(\d{2})-(\d{2})-(.+)\.(md|markdown)$/

  year, month, day, slug = Regexp.last_match(1), Regexp.last_match(2), Regexp.last_match(3), Regexp.last_match(4)
  html_path = File.join(SITE_DIR, year, month, day, "#{slug}.html")
  md_path = File.join(SITE_DIR, year, month, day, "#{slug}.md")
  next unless File.exist?(html_path)

  write_markdown(html_path, md_path)
end

# Pages: about/index.md -> _site/about/index.html -> _site/about.md
%w[about press speaking].each do |dir|
  html_path = File.join(SITE_DIR, dir, 'index.html')
  md_path = File.join(SITE_DIR, "#{dir}.md")
  next unless File.exist?(html_path)

  write_markdown(html_path, md_path)
end
