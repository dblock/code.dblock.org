# frozen_string_literal: true

require 'set'

module Jekyll
  class TopicPages < Generator
    safe true
    priority :high

    def generate(site)
      registry = site.data.fetch('topics', {})
      aliases = {}
      registry.each do |name, topic|
        ([name] + topic.fetch('aliases', [])).each do |label|
          raise "Conflicting topic alias: #{label}" if aliases.key?(label)

          aliases[label] = name
        end
      end
      posts = Hash.new { |hash, key| hash[key] = [] }
      labels = Set.new
      site.posts.docs.each do |post|
        post.data.fetch('tags', []).each { |tag| labels << tag }
        canonical = post.data.fetch('tags', []).map { |tag| aliases.fetch(tag, tag) }.uniq
        post.data['topic_links'] = canonical.map do |tag|
          { 'name' => registry.fetch(tag, {}).fetch('title', tag), 'url' => topic_url(tag) }
        end
        canonical.each { |tag| posts[tag] << post }
      end
      topics = posts.keys.sort.map do |tag|
        items = posts.fetch(tag).sort_by { |post| [post.date, post.data.fetch('title', '').to_s] }.reverse
        config = registry.fetch(tag, {})
        topic = {
          'name' => config.fetch('title', tag),
          'description' => config.fetch('description', ''),
          'count' => items.length,
          'latest' => items.first.date.strftime('%Y-%m-%d'),
          'url' => topic_url(tag)
        }
        page = PageWithoutAFile.new(site, site.source, "tags/#{tag}", 'index.html')
        page.data = topic.merge('layout' => 'tag', 'title' => topic['name'], 'tag' => tag, 'topic_posts' => items)
        site.pages << page
        topic
      end
      labels.merge(aliases.keys.select { |label| posts.key?(aliases.fetch(label)) })
      labels.each do |label|
        canonical = aliases.fetch(label, label)
        next if canonical == label

        page = PageWithoutAFile.new(site, site.source, "tags/#{label}", 'index.html')
        page.data = { 'redirect_to' => topic_url(canonical), 'sitemap' => false }
        site.pages << page
      end
      site.data['topic_index'] = topics
    end

    private

    def topic_url(tag)
      raise "Invalid topic path: #{tag.inspect}" if tag.empty? || tag.match?(%r{[/\\#?]}) || %w[. ..].include?(tag)

      "/tags/#{tag}/"
    end
  end
end
