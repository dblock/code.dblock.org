# frozen_string_literal: true

# Copyright OpenSearch Contributors
# SPDX-License-Identifier: BSD-3-Clause

require 'net/http'
require 'jekyll/hooks'
require 'jekyll/document'
require 'json'
require 'set'
require 'uri'
require 'pathname'
require 'typhoeus'
require 'ruby-link-checker'

#
# Checks links during build to warn or fail upon finding dead links.
#
# `LINK_CHECKER`, set on the environment, will cause verification of external links
# Usage: `LINK_CHECKER=1 bundle exec jekyll build --future`
#

module Jekyll::LinkChecker
  ##
  # The collection that will get stores as the output

  @urls

  ##
  # Pattern to identify documents that should be excluded based on their URL

  @excluded_paths = %r{(\.(css|js|json|map|xml|txt|yml)$|/version-selector\.tpl$)}i.freeze

  ##
  # Pattern to identify certain HTML tags whose content should be excluded from indexing

  @href_matcher = /<a[^>]+href=(['"])(.+?)\1/im.freeze

  ##
  # Pattern to check for external URLs

  @external_matcher = %r{^https?://}.freeze

  ##
  # List of domains to ignore
  @ignored_domains = File.readlines(
    File.join(File.dirname(__FILE__), 'link-checker-exclude-domains.txt')
  ).map(&:strip).compact

  ##
  # List of URLs to ignore
  @ignored_urls = File.readlines(
    File.join(File.dirname(__FILE__), 'link-checker-exclude-urls.txt')
  ).map(&:strip).compact

  ##
  # Pattern of local paths to ignore
  @ignored_paths = %r{(^/tags|^mailto:)}.freeze

  ##
  # Holds the list of failures
  @failures

  ##
  # Build flags driven by environment variables
  @check_links                # Enables the link checker

  ##
  # Defines the priority of the plugin
  # The hooks are registered with a very low priority to make sure they runs after any content modifying hook
  def self.priority
    10
  end

  ##
  # Initializes the singleton by recording the site
  def self.init(site)
    @site = site
    @urls = {}
    @failures = []

    begin
      @check_links = ENV.key?('LINK_CHECKER')

      unless @check_links
        return Jekyll.logger.info 'LinkChecker:', 'disabled. Enable with LINK_CHECKER=1.'
      end

      @external_link_checker = LinkChecker::Typhoeus::Hydra::Checker.new(
        logger: Jekyll.logger,
        hydra: { max_concurrency: 5 },
        retries: 1,
        user_agent: 'dblock.org Link Checker/1.0'
      )

      @external_link_checker.on :failure, :error do |result|
        @failures << "#{result}, linked to in #{result.options[:location]}"
      end

      # Process a Page as soon as its content is ready
      Jekyll::Hooks.register :pages, :post_render, priority: priority do |page|
        process(page)
      end

      # Process a Document as soon as its content is ready
      Jekyll::Hooks.register :documents, :post_render, priority: priority do |document|
        process(document)
      end

      # Verify gathered links after Jekyll is done writing all its stuff
      Jekyll::Hooks.register :site, :post_write, priority: priority do |site|
        verify(site)
      end

      Jekyll.logger.info 'LinkChecker: [Notice] The build will fail if a dead link is found.'
    rescue StandardError => e
      Jekyll.logger.error 'LinkChecker: [Error] Failed to initialize Link Checker.'
      raise
    end
  end

  ##
  # Processes a Document or Page and adds the links to a collection
  # It also checks for anchors to parts of the same page/doc

  def self.process(page)
    return unless @check_links
    return if @excluded_paths.match(page.path)

    hrefs = page.content.scan(@href_matcher)
    hrefs.each do |(_, href)|
      relative_path = page.path[0] == '/' ? Pathname.new(page.path).relative_path_from(Dir.getwd) : page.path

      if href.eql? '#'
        next
      elsif href.start_with? '#'
        Jekyll.logger.info relative_path if (page.content =~ /<[a-z0-9-]+[^>]+(?:id|name)="#{href[1..]}"/i).nil?
        if (page.content =~ /<[a-z0-9-]+[^>]+(?:id|name)="#{href[1..]}"/i).nil?
          @failures << "##{href[1..]}, linked in ./#{relative_path}"
        end
      else
        @urls[href] = Set[] unless @urls.key?(href)
        @urls[href] << relative_path
      end
    end
  end

  def self.verify(_site)
    return unless @check_links

    @base_url_matcher = %r{^#{@site.config["url"]}#{@site.baseurl}(/.*)$}.freeze

    @urls.sort_by { |url, pages| rand }.each do |url, pages|
      location = "./#{pages.to_a.join(', ./')}"
      @failures << "#{url}, linked to in #{location}" unless check(url, location)
    end

    @external_link_checker.run

    unless @failures.empty?
      msg = "Found #{@failures.size} dead link#{@failures.size > 1 ? 's' : ''}:\n#{@failures.join("\n")}"
    end

    if !@failures.empty?
      Jekyll.logger.error "\nLinkChecker: [Error] #{msg}.\n".red
      raise msg
    else
      Jekyll.logger.info "\nLinkChecker: [Success] No broken links!\n".green
    end
  end

  ##
  # Check if URL is accessible

  def self.check(url, location)
    match = @base_url_matcher.match(url)
    url = match[1] unless match.nil?

    if @external_matcher =~ url
      return check_external(url, location)
    else
      check_internal(url, location)
    end
  end

  ##
  # Check if an external URL is accessible

  def self.check_external(url, location)
    Jekyll.logger.info "LinkChecker: [Info] Checking #{url} ...".cyan
    url = begin
      URI(url)
    rescue StandardError
      url
    end
    return true if url.is_a?(URI) && @ignored_domains.include?(url.host)
    return true if url.is_a?(URI) && @ignored_urls.include?(url.to_s)

    @external_link_checker.check(url, { location: location })
  end

  ##
  # Check if an internal link is accessible

  def self.check_internal(url, location)
    Jekyll.logger.info "LinkChecker: [Info] Checking #{url} ...".cyan
    return true if @ignored_paths =~ url

    path, hash = url.split('#')

    unless path =~ %r{\.[^/]{2,}$}
      path << '/' unless path.end_with? '/'
      path << 'index.html' unless path.end_with? 'index.html'
    end

    filename = File.join(@site.config['destination'], path)

    return false unless File.file?(filename)

    content = File.read(filename)
    unless content.include? '<title>Redirecting'
      return true if hash.nil? || hash.empty?

      return !(content =~ /<[a-z0-9-]+[^>]+id="#{hash}"/i).nil?
    end

    match = content.match(@href_matcher)
    if match.nil?
      Jekyll.logger.warn "LinkChecker: [Warning] Cannot check #{url} due to an unfollowable redirect."
      return true
    end

    redirect = match[2]
    redirect << '#' + hash unless hash.nil? || hash.empty?
    check(redirect, location)
  end
end

# Before any Document or Page is processed, initialize the LinkChecker
Jekyll::Hooks.register :site, :pre_render, priority: Jekyll::LinkChecker.priority do |site|
  Jekyll::LinkChecker.init(site)
end