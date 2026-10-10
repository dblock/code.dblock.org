desc 'Build the site, including dynamic topic pages.'
task :tags do
  sh 'bundle exec jekyll build'
end

desc 'Lint Markdown.'
task :lint do
  sh 'npm run lint:markdown'
end

namespace :spell do
  desc 'Check spelling in staged Markdown; check all tracked Markdown when spelling settings change.'
  task :staged do
    require_relative '_lib/staged_spelling'
    StagedSpelling.run
  end
end

desc 'Run commit-time Markdown linting and staged spelling checks.'
task precommit: [:lint, 'spell:staged']

desc 'Check for broken links and such.'
task :check do
  require 'html-proofer'
  sh 'bundle exec jekyll build'
  HTMLProofer.check_directory(
    './_site',
    alt_ignore: [/.*/],
    http_status_ignore: [999]
  ).run
end
