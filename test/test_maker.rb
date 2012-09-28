require_relative 'helper'
require 'fileutils'
require 'epub/maker'

class TestMaker < Test::Unit::TestCase
  def setup
    @file = 'test/fixtures/book.epub'
    FileUtils::Verbose.rm @file if File.exist? @file
  end

  def test_container
    require 'epub/maker/ocf/container'
    container = EPUB::OCF::Container.new
    rootfile = EPUB::OCF::Container::Rootfile.new
    rootfile.full_path = 'OPS/contents.opf'
    rootfile.media_type = 'application/oebps-package+xml'
    container.rootfiles << rootfile
    expected = Nokogiri.XML(<<EOC)
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OPS/contents.opf" media-type="application/oebps-package+xml" />
  </rootfiles>
</container>
EOC
    assert_equal expected.to_s, Nokogiri.XML(container.to_xml).to_s
  end

  def test_make
    EPUB::Maker.make_from_directory 'test/fixtures/book'
    assert_path_exist @file

    # assert that mimetype file not compressed
    # assert validation of file
  end
end
