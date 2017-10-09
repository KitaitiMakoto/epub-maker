require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps/'
end

require 'test/unit'
require 'test/unit/notify'
require 'open3'
require 'shellwords'
require 'pry'
require 'epubcheck/ruby/cli'
class Test::Unit::TestCase
  def assert_valid_epub(file)
    if ENV["GITLAB_CI"]
      warn "Validating EPUB file loosly by EPUB::Parser.parse instead of EpubCheck"
      assert_nothing_raised do
        EPUB::Parser.parse file
      end
    else
      assert_true Epubcheck::Ruby::CLI.new.execute(file)
    end
  end
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epub'
