# frozen_string_literal: true

require 'json'
require 'set'
require 'rubocop-spellcheck'

root = File.expand_path('../..', __dir__)
paths = IO.popen(['git', '-C', root, 'ls-files', '-z'], &:read).split("\0").select do |path|
  %w[.md .markdown].include?(File.extname(path)) &&
    (path.split('/') & %w[_site _styles node_modules vendor]).empty?
end
start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
words = paths.flat_map do |path|
  buffer = Parser::Source::Buffer.new(path, source: File.read(File.join(root, path)))
  RuboCop::Spellcheck::Markdown.new(buffer).each_span.flat_map do |text, _positions|
    text = text.sub(/\A['’]s\b/, '  ')
    text = text.gsub(%r{(?:https?://|www\.)[^\s<>]+|[\w.+-]+@[\w.-]+\.[a-zA-Z]{2,}}, ' ')
    text.scan(RuboCop::Spellcheck::Checker::ENGLISH_WORD)
  end
end
extraction_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
vocabulary = File.readlines(File.join(root, '.spellcheck.txt'), chomp: true)
                 .reject { |word| word.empty? || word.start_with?('#') }.to_set(&:downcase)
dictionary_root = Gem.loaded_specs.fetch('rubocop-spellcheck').full_gem_path
dic = File.join(dictionary_root, 'data/en/en.dic')
aff = File.join(dictionary_root, 'data/en/en.aff')
abort 'Rust engine is unavailable' unless Kotoshu::Native.available?
metadata = { files: paths.length, tokens: words.length, unique_words: words.uniq.length,
             kotoshu: Kotoshu::VERSION, native: Kotoshu::Native::VERSION, extraction_seconds: extraction_seconds }
puts JSON.generate(metadata)
results = []
3.times do |round|
  %w[ruby rust].each do |backend|
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    checker = if backend == 'ruby'
                dictionary = Kotoshu::Dictionary::Hunspell.new(dic_path: dic, aff_path: aff, language_code: 'en')
                config = Kotoshu::Configuration.new(language: 'en', offline: true,
                                                    personal_dictionary: false, backend: 'ruby')
                Kotoshu::Spellchecker.new(dictionary: dictionary, config: config)
              else
                Kotoshu::Native::Dictionary.load(aff, dic)
              end
    load_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    verdicts = words.uniq.to_h { |word| [word, vocabulary.include?(word.downcase) || checker.correct?(word)] }
    unique_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    misses = words.count { |word| !verdicts.fetch(word) }
    scan_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
    result = { backend: backend, round: round + 1, load_seconds: load_seconds,
               unique_check_seconds: unique_seconds, cached_scan_seconds: scan_seconds,
               misspelled_tokens: misses, misspelled_words: verdicts.count { |_word, correct| !correct } }
    results << result
    puts JSON.generate(result)
    $stdout.flush
  end
end
File.write(File.join(__dir__, 'kotoshu-results.json'),
           "#{JSON.pretty_generate(metadata: metadata, results: results)}\n")
