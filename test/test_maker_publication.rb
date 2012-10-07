# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/parser/publication'
require 'epub/maker/publication'

class TestMakerPublication < Test::Unit::TestCase
  def setup
    rootfile = 'OPS/ルートファイル.opf'
    @opf = File.read(File.expand_path("../fixtures/book/#{rootfile}", __FILE__))
    @package = EPUB::Parser::Publication.new(@opf, rootfile).parse
  end

  def test_to_xml_attribute
    actual = Nokogiri.XML(@package.to_xml).xpath('/opf:package/opf:metadata/dc:identifier', EPUB::NAMESPACES).first
    assert_equal 'pub-id', actual['id']
  end
end
