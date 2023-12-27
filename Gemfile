source 'https://rubygems.org'

if ENV["EPUB_PARSER_PATH"]
  group :development do
    gem 'epub-parser', path: ENV["EPUB_PARSER_PATH"]
  end
end

gemspec

if RUBY_PLATFORM.match /darwin/
  gem 'terminal-notifier'
end
