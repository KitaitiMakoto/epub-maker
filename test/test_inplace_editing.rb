require_relative 'helper'
require 'epub/maker'

class TestInplaceEditing < Test::Unit::TestCase
  def setup
    @assets_dir = Pathname(__dir__)/'fixtures'/'book'
    @dir = Pathname.mktmpdir('epub-maker-test')
    @file = @dir/'book.epub'
    EPUB::Maker.archive @assets_dir, @file
    @book = EPUB::Parser.parse(@file)
    @valid_epub = @dir/valid_epub.basename
    FileUtils.cp valid_epub, @valid_epub
  end

  def teardown
    @dir.remove_entry_secure if @dir.exist?
  end

  def test_save_parsed_book
    nav = @book.nav
    doc = nav.content_document.nokogiri
    title = doc.search('title').first
    title.content = 'Edited Title'
    nav.content = doc.to_xml
    nav.save

    assert_match '<title>Edited Title</title>', nav.read
  end

  def test_edit
    item = @book.resources.find(&:xhtml?)
    item.edit do
      doc = Nokogiri.XML(item.read)
      title = doc.search('title').first
      title.content = 'Edited Title'
      item.content = doc.to_xml
    end

    assert_match '<title>Edited Title</title>', item.read
  end

  def test_edit_with_rexml
    require 'rexml/quickpath'
    item = @book.resources.find(&:xhtml?)
    item.edit_with_rexml do |doc|
      title = REXML::QuickPath.first(doc, '//title')
      title.text = 'Edited Title'
    end

    assert_match '<title>Edited Title</title>', item.read
  end

  def test_edit_with_nokogiri
    item = @book.resources.find(&:xhtml?)
    item.edit_with_nokogiri do |doc|
      title = doc.search('title').first
      title.content = 'Edited Title'
    end

    assert_match '<title>Edited Title</title>', item.read
  end

  def test_edit_without_change
    epub = EPUB::Parser.parse(@valid_epub)
    epub.save
    assert_equal epub.release_identifier, EPUB::Parser.parse(@valid_epub).release_identifier
  end

  def test_specify_mtime
    # Currently, only ArchiveZip supports this API
    EPUB::OCF::PhysicalContainer.adapter = :ArchiveZip
    mtime = EPUB::OCF::PhysicalContainer.mtime = Time.new(2020, 1, 1)
    epub = EPUB::Parser.parse(@valid_epub)
    epub.metadata.unique_identifier.content = "new-unique-identifier"
    epub.package.save

    Archive::Zip.open @valid_epub.to_path do |z|
      z.each do |entry|
        assert_equal mtime, entry.mtime
      end
    end
  end
end
