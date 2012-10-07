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
    doc = Nokogiri.XML(@package.to_xml)

    identifier = doc.xpath('/opf:package/opf:metadata/dc:identifier', EPUB::NAMESPACES).first
    assert_equal 'pub-id', identifier['id']

    meta = doc.xpath('/opf:package/opf:metadata/opf:meta[@scheme]', EPUB::NAMESPACES).first
    assert_equal 'marc:relators', meta['scheme']

    link = doc.xpath('/opf:package/opf:metadata/opf:link[@refines]', EPUB::NAMESPACES).first
    assert_equal 'http://example.org/onix/12389347', link['href']
  end
end
