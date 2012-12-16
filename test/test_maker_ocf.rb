require_relative 'helper'
require 'nokogiri'
require 'epub/constants'
require 'epub/maker/ocf'

class TestMakerOCF < Test::Unit::TestCase
  def setup
    @container = EPUB::OCF::Container.new
    rootfile = EPUB::OCF::Container::Rootfile.new
    rootfile.full_path = 'OPS/contents.opf'
    rootfile.media_type = 'application/oebps-package+xml'
    @container.rootfiles << rootfile
  end

  def test_container
    expected = Nokogiri.XML(<<EOC)
<?xml version="1.0" encoding="UTF-8"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
  <rootfiles>
    <rootfile full-path="OPS/contents.opf" media-type="application/oebps-package+xml" />
  </rootfiles>
</container>
EOC
    assert_equal expected.to_s, Nokogiri.XML(@container.to_xml).to_s
  end
end
