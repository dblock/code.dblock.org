# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'jekyll'
require_relative '../_plugins/link-checker'

class LinkCheckerTest < Minitest::Test
  def setup
    @environment = ENV.to_h.slice('LINK_CHECKER', 'LINK_CHECKER_CACHE')
    ENV['LINK_CHECKER'] = '1'
    ENV.delete('LINK_CHECKER_CACHE')
    Typhoeus.stub('https://example.com/').and_return(Typhoeus::Response.new(code: 200))
  end

  def teardown
    %w[LINK_CHECKER LINK_CHECKER_CACHE].each { |key| ENV.delete(key) }
    ENV.update(@environment)
    Typhoeus::Expectation.clear
  end

  def check_link
    Jekyll::LinkChecker.init(nil)
    checker = Jekyll::LinkChecker.instance_variable_get(:@external_link_checker)
    results = []
    checker.on(:success) { |result| results << result }
    checker.check('https://example.com/')
    checker.run
    results.fetch(0)
  end

  def test_reuses_success_between_builds_and_expires_after_30_days
    Dir.mktmpdir do |directory|
      ENV['LINK_CHECKER_CACHE'] = File.join(directory, 'links.json')

      refute check_link.cached?
      assert check_link.cached?

      data = JSON.parse(File.read(ENV.fetch('LINK_CHECKER_CACHE')))
      data.fetch('entries').each_value { |entry| entry['checked_at'] = Time.now.to_f - (29 * 24 * 60 * 60) }
      File.write(ENV.fetch('LINK_CHECKER_CACHE'), JSON.generate(data))

      assert check_link.cached?

      data.fetch('entries').each_value { |entry| entry['checked_at'] = Time.now.to_f - (31 * 24 * 60 * 60) }
      File.write(ENV.fetch('LINK_CHECKER_CACHE'), JSON.generate(data))

      refute check_link.cached?
    end
  end

  def test_checks_again_without_a_cache_file_as_in_ci
    refute check_link.cached?
    refute check_link.cached?
  end
end
