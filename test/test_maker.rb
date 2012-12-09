# -*- coding: utf-8 -*-
require_relative 'helper'
require 'fileutils'
require 'epub/maker'

class TestMaker < Test::Unit::TestCase
  def setup
    @file = 'test/fixtures/book.epub'
    FileUtils::Verbose.rm @file if File.exist? @file
  end

  def test_make_from_package_document
    opf_path = 'test/fixtures/book/OPS/ルートファイル.opf'
    EPUB::Maker.make_from_package_document opf_path, 'test/fixtures/book'
    assert false
  end

  def test_make_from_directory
    EPUB::Maker.make_from_directory 'test/fixtures/book'
    assert_path_exist @file

    # assert that mimetype file not compressed
    # assert validation of file
  end

  def test_define_title_as_single_string
    title = 'Title of book'
    epub_book = EPUB::Maker.make {|book|
      book.title = title
    }
    title_elem = Nokogiri.XML(epub_book.package.to_xml).xpath('/opf:package/opf:metadata/opf:title').first
    assert_equal title, title_elem.content
  end
end
