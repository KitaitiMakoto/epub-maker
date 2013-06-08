# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epub/maker/version'

Gem::Specification.new do |gem|
  gem.name          = "epub-maker"
  gem.version       = EPUB::Maker::VERSION
  gem.authors       = ["KITAITI Makoto"]
  gem.email         = ["KitaitiMakoto@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.files.delete '"test/fixtures/book/OPS/\343\203\253\343\203\274\343\203\210\343\203\225\343\202\241\343\202\244\343\203\253.opf"'
  gem.files.push('test/fixtures/book/OPS/ルートファイル.opf')
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.required_ruby_version = '>= 2.0.0'

  gem.add_runtime_dependency 'zipruby'
  gem.add_runtime_dependency 'epub-parser'
  gem.add_runtime_dependency 'pathname-common_prefix'
  gem.add_runtime_dependency 'mime-types'
  gem.add_runtime_dependency 'ruby-uuid'
  gem.add_runtime_dependency 'archive-zip'
  gem.add_runtime_dependency 'rake'

  gem.add_development_dependency 'test-unit-full'
  gem.add_development_dependency 'epubcheck'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-doc'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'gem-man'
  gem.add_development_dependency 'ronn'
end
