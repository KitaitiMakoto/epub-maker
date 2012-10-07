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
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'epub-parser'
  gem.add_runtime_dependency 'pathname-common_prefix'
  gem.add_runtime_dependency 'mime-types'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'test-unit-full'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'pry-doc'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'gem-man'
  gem.add_development_dependency 'ronn'
end
