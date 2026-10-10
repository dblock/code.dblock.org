# frozen_string_literal: true

require 'fileutils'
require 'open3'
require 'tmpdir'

module StagedSpelling
  CONFIG = '.pyspelling.yml'
  DICTIONARY = '.pyspelling.words'
  EXCLUDED = %w[_site _styles node_modules vendor].freeze

  def self.git(*args)
    output, status = Open3.capture2('git', *args)
    raise "Git failed: #{args.join(' ')}" unless status.success?

    output
  end

  def self.markdown?(path)
    %w[.md .markdown].include?(File.extname(path)) && (path.split('/') & EXCLUDED).empty?
  end

  def self.run(checker: ->(command, directory) { system(*command, chdir: directory) })
    root = git('rev-parse', '--show-toplevel').strip
    Dir.chdir(root) do
      changed = git('diff', '--cached', '--name-only', '-z', '--diff-filter=ACMR').split("\0")
      deleted = git('diff', '--cached', '--name-only', '-z', '--diff-filter=D').split("\0")
      raise 'The spelling configuration and dictionary must not be deleted.' unless
        (deleted & [CONFIG, DICTIONARY]).empty?

      full = !(changed & [CONFIG, DICTIONARY]).empty?
      sources = (full ? git('ls-files', '-z').split("\0") : changed).select { |path| markdown?(path) }
      if sources.empty?
        puts 'No staged Markdown files to spell-check.'
        return
      end

      puts "Spell-checking #{sources.length} staged Markdown files#{full ? ' (configuration or dictionary changed)' : ''}."
      Dir.mktmpdir('spell-staged-') do |directory|
        [CONFIG, DICTIONARY, *sources].each do |path|
          target = File.join(directory, path)
          FileUtils.mkdir_p(File.dirname(target))
          File.binwrite(target, git('show', ":#{path}"))
        end
        command = ['pyspelling', '--config', CONFIG, '--name', 'Markdown']
        sources.each do |path|
          command.concat(['--source', path.gsub(/[\\*?\[\]{}()!|]/) { |character| "\\#{character}" }])
        end
        raise 'PySpelling failed. Please fix spelling errors before committing.' unless checker.call(command, directory)
      end
    end
  end
end
