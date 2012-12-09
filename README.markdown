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
    
    EPUB::Maker.make do |book|
      book.title = 'Title of book'
      book.titles = ['Main Title',
                     EPUB::Publication::Package::Metadata::Title.new.tap {|t| t.content = 'Subtitle'}]
      book.authors = ['Author 1', 'Author 2']
      book.authors << 'Additional Author'
      # ...
    
      book.items = %w[path/to/xhtml path/to/another/xhtml path/to/css path/to/image]
      book.spine = %w[path/to/xhtml1 path/to/xhtml2 ... path/to/xhtml12]
      # book.spine = book.items.select {|item| item.media_type.media_type == 'application/xhtml+xml'}.sort
    end

Todo
----
* Multibyte filename(maybe the issue of libzip)

Contributing
------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
