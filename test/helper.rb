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
    assert_true Epubcheck::Ruby::CLI.new.execute(file)
  end
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epub'
