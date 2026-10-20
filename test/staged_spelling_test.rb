# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../_lib/staged_spelling'

class StagedSpellingTest < Minitest::Test
  def setup
    @cwd = Dir.pwd
    @directory = Dir.mktmpdir
    Dir.chdir(@directory)
    StagedSpelling.git('init', '-q')
    {
      '.rubocop.yml' => 'plugins: [rubocop-spellcheck]',
      '.spellcheck.txt' => 'Jekyll',
      'Gemfile' => "source 'https://rubygems.org'",
      'Gemfile.lock' => '',
      'old.md' => 'old',
      'deleted.md' => 'deleted',
      '_styles/ignored.md' => 'ignored'
    }.each { |path, content| write(path, content) }
    StagedSpelling.git('add', '.')
    StagedSpelling.git('-c', 'user.name=Test', '-c', 'user.email=test@example.com',
                       '-c', 'core.hooksPath=/dev/null', 'commit', '-qm', 'initial')
  end

  def teardown
    Dir.chdir(@cwd)
    FileUtils.remove_entry(@directory)
  end

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def test_staged_content_and_literal_paths
    name = 'post [one] with spaces.markdown'
    write(name, 'staged')
    write('_styles/ignored.md', 'changed')
    StagedSpelling.git('add', '.')
    StagedSpelling.git('rm', '-q', 'deleted.md')
    write(name, 'unstaged')
    StagedSpelling.run(checker: lambda { |command, directory|
      assert_equal 'staged', File.read(File.join(directory, name))
      refute File.exist?(File.join(directory, 'deleted.md'))
      refute File.exist?(File.join(directory, '_styles/ignored.md'))
      assert_equal name, command.last
      assert_equal %w[bundle exec rubocop], command.first(3)
      assert_equal '.rubocop.yml', command[command.index('--config') + 1]
      true
    })
  end

  def test_dictionary_triggers_full_staged_check
    write('.spellcheck.txt', "Jekyll\nRuby")
    StagedSpelling.git('add', '.spellcheck.txt')
    write('old.md', 'unstaged')
    StagedSpelling.run(checker: lambda { |command, directory|
      assert_equal 'old', File.read(File.join(directory, 'old.md'))
      assert_equal %w[deleted.md old.md], command.drop(command.index('--') + 1)
      true
    })
  end

  def test_no_markdown_skips_checker
    StagedSpelling.run(checker: ->(*) { flunk 'Checker should not run' })
  end

  def test_dependency_changes_trigger_full_staged_check
    write('Gemfile.lock', 'updated')
    StagedSpelling.git('add', 'Gemfile.lock')
    write('Gemfile.lock', 'unstaged')
    StagedSpelling.run(checker: lambda { |command, directory|
      assert_equal 'updated', File.read(File.join(directory, 'Gemfile.lock'))
      assert_equal %w[deleted.md old.md], command.drop(command.index('--') + 1)
      true
    })
  end

  def test_checker_failure_is_reported
    write('old.md', 'changed')
    StagedSpelling.git('add', 'old.md')
    assert_raises(RuntimeError) { StagedSpelling.run(checker: ->(*) { false }) }
  end

  def test_deleted_configuration_fails
    StagedSpelling.git('rm', '-q', '.rubocop.yml')
    assert_raises(RuntimeError) { StagedSpelling.run }
  end
end
