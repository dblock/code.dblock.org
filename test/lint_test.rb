# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'tempfile'

class LintTest < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def lint(source, *arguments)
    Tempfile.create(['lint-', '.markdown'], File.join(ROOT, '_posts')) do |file|
      file.write(source)
      file.close
      output, errors, status = Open3.capture3(
        'bundle', 'exec', 'rubocop', '--format', 'json', *arguments, file.path, chdir: ROOT
      )
      [JSON.parse(output), File.read(file.path), status, errors]
    end
  end

  def test_prose_and_ruby_autocorrection_preserves_front_matter_and_liquid
    source = <<~MARKDOWN
      ---
      title: "Lint integration"
      ---
      A paragraph with {{ site.url }}
      continues here.

      ```ruby
      value=1
      ```
    MARKDOWN

    report, corrected, status, errors = lint(source, '-a', '--only', 'Prose/MaxLength,Layout/SpaceAroundOperators')

    assert status.success?, errors
    assert_equal %w[Layout/SpaceAroundOperators Prose/MaxLength],
                 report.fetch('files').flat_map { |file|
                   file.fetch('offenses').map { |offense|
                     offense.fetch('cop_name')
                   }
                 }.sort
    assert_equal source.sub("{{ site.url }}\ncontinues", '{{ site.url }} continues').sub('value=1', 'value = 1'),
                 corrected
  end

  def test_spelling_checks_original_prose_title_and_ruby_strings_but_not_identifiers
    source = <<~MARKDOWN
      ---
      title: qzxwvuts
      ---
      qzxvzzzz

      ```ruby
      qzxidentifier = 'qzxcode'
      ```
    MARKDOWN

    report, corrected, status, = lint(source, '--only', 'Spellcheck/Spelling')

    assert_equal 1, status.exitstatus
    assert_equal [2, 4, 7], report.fetch('files').flat_map { |file|
      file.fetch('offenses').map { |offense| offense.fetch('location').fetch('start_line') }
    }.sort
    assert_equal source, corrected
  end
end
