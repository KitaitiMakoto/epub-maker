source 'https://rubygems.org'

if ENV['EDGE_PARSER'] == '1'
  group :development do
    gem 'epub-parser', path: '../epub-parser'
  end
end

gemspec

if RUBY_PLATFORM.match /darwin/
  gem 'terminal-notifier'
end
