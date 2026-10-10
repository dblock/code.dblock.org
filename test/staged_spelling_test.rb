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
      '.pyspelling.yml' => 'matrix: []',
      '.pyspelling.words' => 'Jekyll',
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
      assert_equal 'post \\[one\\] with spaces.markdown', command.last
      true
    })
  end

  def test_dictionary_triggers_full_staged_check
    write('.pyspelling.words', "Jekyll\nRuby")
    StagedSpelling.git('add', '.pyspelling.words')
    write('old.md', 'unstaged')
    StagedSpelling.run(checker: lambda { |command, directory|
      assert_equal 'old', File.read(File.join(directory, 'old.md'))
      assert_equal 2, command.count('--source')
      true
    })
  end

  def test_no_markdown_skips_checker
    StagedSpelling.run(checker: ->(*) { flunk 'Checker should not run' })
  end

  def test_checker_failure_is_reported
    write('old.md', 'changed')
    StagedSpelling.git('add', 'old.md')
    assert_raises(RuntimeError) { StagedSpelling.run(checker: ->(*) { false }) }
  end

  def test_deleted_configuration_fails
    StagedSpelling.git('rm', '-q', '.pyspelling.yml')
    assert_raises(RuntimeError) { StagedSpelling.run }
  end
end
