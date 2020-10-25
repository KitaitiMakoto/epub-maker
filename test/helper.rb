require 'simplecov'
SimpleCov.start do
  add_filter /test|deps/
end

require 'test/unit'
require 'test/unit/notify'
require 'pry'
require 'epubcheck/ruby/cli'
class Test::Unit::TestCase
  def assert_valid_epub(file)
    assert_true Epubcheck::Ruby::CLI.new.execute(file)
  end

  private

  def valid_epub
    Pathname.new("test/fixtures/accessible_epub_3.epub")
  end
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epub'
