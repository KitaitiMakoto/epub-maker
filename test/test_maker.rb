# -*- coding: utf-8 -*-
require_relative 'helper'
require 'tmpdir'
require 'fileutils'
require 'epub/maker'

class TestMaker < Test::Unit::TestCase
  def setup
    @fixture_dir = Pathname(__dir__) + 'fixtures' + 'book'
    @dir = Pathname.mktmpdir('epub-maker-test')
    @file = @dir + 'book.epub'
  end

  def teardown
    @dir.remove_entry_secure if @dir.exist?
  end

  def test_make
    EPUB::Maker.make @file do |book|
      book.make_ocf do |ocf|
        ocf.make_container do |container|
          container.make_rootfile full_path: 'OPS/content.opf'
        end
      end

      book.make_package do |package|
        package.dir = 'rtl'

        package.make_metadata do |metadata|
          metadata.title = 'Sample eBook'
          metadata.language = 'ja'
        end

        package.make_manifest do |manifest|
          Pathname.glob("#{@fixture_dir}/OPS/*.{xhtml,xml}").each_with_index do |content_path, index|
            manifest.make_item do |item|
              item.id = "item-#{index + 1}"
              href = content_path.relative_path_from(@fixture_dir + File.dirname(book.rootfile_path))
              item.href = Addressable::URI.parse(href.to_s)
              item.media_type = case content_path.extname
                                when '.xhtml' then 'application/xhtml+xml'
                                when '.xml' then 'application/xml'
                                end
              item.content_file = (@fixture_dir + item.entry_name).to_path
              item.properties << 'nav' if content_path.basename.to_path == 'nav.xhtml'
            end
          end

          package.make_spine do |spine|
            spine.page_progression_direction = 'rtl'

            package.manifest.items.select(&:xhtml?).each do |item|
              spine.make_itemref do |itemref|
                itemref.item = item
                itemref.linear = true
              end
            end
          end
        end
      end
    end

    assert_valid_epub @file.to_path
  end
end
