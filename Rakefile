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

desc 'Build the site, including future posts, and check links as in CI.'
task :links do
  sh({ 'LINK_CHECKER' => '1' }, 'bundle exec jekyll build --future')
end

desc 'Build the site and check for broken links.'
task check: :links
