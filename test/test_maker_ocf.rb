require_relative 'helper'
require 'nokogiri'
require 'epub/constants'
require 'epub/maker/ocf'

class TestMakerOCF < Test::Unit::TestCase
  def setup
    @container = EPUB::OCF::Container.new
  end

  def test_make_container_returns_container_object
    ocf = EPUB::OCF.new
    assert_kind_of EPUB::OCF::Container, ocf.make_container
  end

  def test_make_container_yields_container_object
    ocf = EPUB::OCF.new
    ocf.make_container do |container|
      assert_kind_of EPUB::OCF::Container, container
    end
  end

  def test_container_make_container_yeilds_is_a_container_of_the_ocf
    ocf = EPUB::OCF.new
    container = ocf.make_container
    assert_same ocf.container, container
  end

  class TestMakerContainer < TestMakerOCF
    def test_to_xml
      rootfile = EPUB::OCF::Container::Rootfile.new
      rootfile.full_path = 'OPS/contents.opf'
      rootfile.media_type = 'application/oebps-package+xml'
      @container.rootfiles << rootfile
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

    def test_make_rootfile_returnes_rootfile_object
      assert_kind_of EPUB::OCF::Container::Rootfile, @container.make_rootfile
    end

    def test_make_rootfile_yields_rootfile_object
      @container.make_rootfile do |rootfile|
        assert_kind_of EPUB::OCF::Container::Rootfile, rootfile
      end
    end

    def test_rootfile_make_rootfile_yields_is_a_rootfile_of_the_container
      rootfile = @container.make_rootfile
      assert_include @container.rootfiles, rootfile
    end
  end
end
