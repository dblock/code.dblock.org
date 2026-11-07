# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |task|
  task.pattern = 'test/*_test.rb'
end

desc 'Build the site, including dynamic topic pages.'
task :tags do
  sh 'bundle exec jekyll build'
end

desc 'Lint prose, Ruby files, and Ruby code fences.'
task :lint do
  sh 'bundle exec rubocop --except Spellcheck/Spelling'
end

namespace :spell do
  desc 'Check spelling in all Markdown files.'
  task :check do
    sh 'bundle exec rubocop --only Spellcheck/Spelling'
  end

  desc 'Check spelling in staged Markdown; check all tracked Markdown when spelling settings change.'
  task :staged do
    require_relative '_lib/staged_spelling'
    StagedSpelling.run
  end
end

desc 'Run commit-time Markdown linting and staged spelling checks.'
task precommit: [:lint, 'spell:staged']

desc 'Check links in the already-built site.'
task :links do
  require 'html-proofer'
  HTMLProofer.check_directory(
    './_site',
    alt_ignore: [/.*/],
    http_status_ignore: [999]
  ).run
end

desc 'Build the site and check for broken links.'
task check: %i[tags links]
