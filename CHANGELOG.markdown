0.1.8
-----

* Add adapter for Rubyzip

0.1.7
-----

* Remove version specification from Nokogiri to migrate to Ruby 3.1

0.1.6
-----

* [BUG FIX]Add `mtime` keyword argument to `OCF::PhysicalContainer::Zipruby#write`

0.1.5
-----

* [BUG FIX]Compare path name in the same encoding when finding file in ZIP archive
* Add `PhysicalContaienr.mtime` API to set mtime of files in EPUB archive

0.1.4
-----

* Add `Publication::Package::Metadata#modified=` method
* Rescue Errno::EXDEV on renaming temporary EPUB file

0.1.3
-----

* Add workaround Window file renaming problem

0.1.2
------

* Close temp file when archiving EPUB file

0.1.1
-----

* Update Nokogiri version to < 1.11

0.1.0
-----

* [BUG FIX]Fix the case file extension should be wrong
* Add Nokogiri to runtime dependencies explicitly

0.0.9
-----

* Remove [ruby-uuid][] gem from dependencies
* [BUG FIX]Convert Set to Array before writing into XML
* Follow change of EPUB Parser v0.3.6

0.0.8
-----

* Use default temporary directory for `EPUB::Maker.archive` to avoid working on world writable place

0.0.7
-----

* Change temporary directory used by `EPUB::Maker.archive` to avoid Error::EXDEV Invalid cross-device link @ rb_file_s_rename

0.0.6
-----

* Add `epub-archive` command
* Add `EPUB::Maker.archive` method

0.0.5
-----

* Fix bug to modify `dc:rights` to `dc:right`

0.0.4
-----

* API change: #save -> #write for PhysicalContainer classes
* Bump required EPUB Parser version: 0.2.0 -> 0.2.6
* Deprecate `EPUB::OCF::PhysicalContainer.save`

0.0.3
-----

* Bump up required Ruby version: >= 2.0.0 -> >= 2.1.0
* Use PhysicalContainer to save contents into EPUB file

0.0.2
-----

* Detect media type of files more strictly by using MimeMagic
* Keep temporary directory remained on error in `EPUB::Maker.make` to help research about it
* Define `EPUB::Package#edit`
* Make `EPUB::Package#save` able to replace content as well as add
* Define `EPUB::Package::Metadata::Meta#valid?`
* Drop invalid meta element in metadata on save

0.0.1
------

* Initial release!
