require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps/'
end

require 'test/unit/full'
class Test::Unit::TestCase
  def assert_valid_epub(file)
    jar = File.join(ENV['GEM_HOME'], 'gems', 'epubcheck-3.0.0', 'lib', 'epubcheck-3.0', 'epubcheck-3.0.jar')
    assert_true system('java', '-jar', jar, file)
  end
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epub'
