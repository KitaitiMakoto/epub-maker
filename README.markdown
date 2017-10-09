EPUB Maker
==========

This library supports making and editing EPUB books

Installation
------------

Add this line to your application's Gemfile:

    gem 'epub-maker'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install epub-maker

Usage
-----

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
                                when '.png' then 'image/png'
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

For structure of EPUB book, see [EPUB Parser's documentation][epub-parser-doc].

### In-place editing

    require 'epub/maker'
    
    book = EPUB::Parser.parse('path/to/book.epub')
    book.resources.select(&:xhtml?).each do |item|
      doc = item.content_document.nokogiri
      title = doc/'title'
      title.content += ' - Additional Title such like book title'
      item.content = doc.to_xml
      item.save
    end

Shortcut:

    book.resources.select(&:xhtml?).each do |item|
      item.edit_with_nokogiri do |doc| # Nokogiri::XML::Document is passed to block
        doc.search('img').each do |img|
          img['alt'] = '' if img['alt'].nil?
        end
      end # item.content = doc.to_xml is called automatically
    end # item.save is called automatically

For APIs of parsed EPUB book, see [EPUB Parser's documentation][epub-parser-doc].

[epub-parser-doc]: http://rubydoc.info/gems/epub-parser/frames

### Rake task ###

**CAUTION**: Still work in progress. File path to require and API will be modified in the future.

    require 'epub/maker/task'

    DIR = 'path/to/dir/holding/contents'
    EPUB_FILE = DIR + '.epub'
    EPUB::Maker::Task.new EPUB_FILE do |task|
      task.titles = ['EPUB Maker Rake Example']

      task.base_dir = DIR

      task.files.include "#{task.base_dir}/**/*"
      task.files.exclude {|entry| ! File.file? entry}

      task.rootfile = "#{DIR}/OPS/contents.opf"
      task.make_rootfiles = true

      task.resources = task.files.dup
      task.resources.exclude /\.opf/
      task.resources.exclude /META\-INF/

      task.navs.include 'OPS/nav.xhtml'
      task.media_types = {"#{DIR}/OPS/slideshow.xml" => 'application/x-demo-slideshow'}

      task.spine = task.resources.dup
      task.spine.exclude /OPS\/impl\.xhtml\z/
      task.spine.exclude /\.xml\z/

      task.bindings = {'application/x-demo-slideshow' => "#{DIR}/OPS/impl.xhtml"}
    end

### epub-archive command

`epub-archive` command archives given directory as an EPUB file like [epzip][] gem but doesn't require zip command.

    % ls path/to
    book
    % epub-archie path/to/book
    % ls path/to
    book
    book.epub

You can specify target file path.

    % epub-archive source/dir/book target/dir/book.epub
    % ls source/dir
    book
    % ls target/dir
    book.epub

[epzip]: https://github.com/takahashim/epzip

Requirements
------------
* Ruby 2.2 or later
* C compiler to build Nokogiri gems

Todo
----
* Encode filenames as UTF-8 on adding them to package
* Refine Rake task
  * Autodetection of media types
* Makable from directory/package document file

Recent Changes
--------------
### 0.0.6

* Add `epub-archive` command
* Add `EPUB::Maker.archive` method

### 0.0.5

* Fix bug to modify `dc:rights` to `dc:right`

### 0.0.4
* API change: #save -> #write for PhysicalContainer classes
* Bump required EPUB Parser version: 0.2.0 -> 0.2.6
* Deprecate `EPUB::OCF::PhysicalContainer.save`

### 0.0.3
* Bump up required Ruby version: >= 2.0.0 -> >= 2.1.0

### 0.0.2
* Detect media type of files more strictly
* Keep temporary directory remained on error in `EPUB::Maker.make`
* Define `EPUB::Package#edit`
* Make `EPUB::Package#save` able to replace content as well as add
* Define `EPUB::Package::Metadata::Meta#valid?`
* Drop invalid meta element in metadata on save

### 0.0.1
* Initial release!

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
