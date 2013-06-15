require_relative 'helper'
require 'epub/maker'
require 'epzip'

class TestImplaceEditing < Test::Unit::TestCase
  def setup
    @assets_dir = Pathname(__dir__)/'fixtures'/'book'
    @dir = Pathname.mktmpdir('epub-maker-test')
    @file = @dir/'book.epub'
    Epzip.zip @assets_dir.to_s, @file.to_path
  end

  def teardown
    (@assets_dir/'mimetype').rmtree
    @dir.remove_entry_secure if @dir.exist?
  end

  def test_save_parsed_book
    book = EPUB::Parser.parse(@file)
    nav = book.nav
    doc = nav.content_document.nokogiri
    title = doc.search('title').first
    title.content = 'Edited Title'
    nav.content = doc.to_xml
    nav.save

    assert_match '<title>Edited Title</title>', nav.read
  end

  def test_edit
    assert false
  end
end
