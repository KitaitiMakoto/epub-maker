0.0.4
-----

* API change: #save -> #write for PhysicalContainer classes

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
