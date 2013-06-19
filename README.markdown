EPUB Maker
==========

This library supports making EPUB ebooks and provides commands for it.

Installation
------------

<!--
Add this line to your application's Gemfile:

    gem 'epub-maker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install epub-maker
-->

Usage
-----

### Command-line tools ###


### Library ###

    require 'epub/maker'
    
    EPUB::Maker.make path/to/generated/book.epub do |book|
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

### Rake task ###

Stil work in progress.

### In-place editing

    require 'epub/maker'
    
    book = EPUB::Parser.parse('path/to/book.epub', EPUB::Maker::EDIT_MODE)
    book.resources.select(&:xhtml?).each do |item|
      doc = item.content_document.nokogiri
      title = doc/'title'
      title.content += ' - Additional Title such like book title'
      item.content = doc.to_xml
      item.save
    end

Shortcut:

    book.resources.select(&:xhtml?).each do |item|
      item.edit_with_nokogiri do |doc|
        doc.search('img').each do |img|
          img['alt'] = '' if img['alt'].nil?
        end
      end
    end
    # Automatically saved

Todo
----
* Rake task

Recent Changes
--------------
* 0.0.1/Initial release!

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
