require_relative 'helper'
require 'fileutils'
require 'epub/maker'

class TestMaker < Test::Unit::TestCase
  def setup
    @file = 'test/fixtures/book.epub'
    FileUtils::Verbose.rm @file if File.exist? @file
  end

  def test_make
    EPUB::Maker.make_from_directory 'test/fixtures/book'
    assert_path_exist @file

    # assert that mimetype file not compressed
    # assert validation of file
  end
end
