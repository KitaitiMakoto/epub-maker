require 'simplecov'
SimpleCov.start do
  add_filter '/test|deps/'
end

require 'test/unit/full'
require 'open3'
require 'shellwords'
require 'pry'
class Test::Unit::TestCase
  def assert_valid_epub(file)
    jar = File.join(ENV['GEM_HOME'], 'gems', 'epubcheck-3.0.0', 'lib', 'epubcheck-3.0', 'epubcheck-3.0.jar')
    stderr, status = Open3.capture2e "java -jar #{jar.shellescape} #{file.shellescape}"
    assert_true (status.exitstatus == 0 or stderr !~ /^ERROR: /), stderr
  end
end
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'epub'
