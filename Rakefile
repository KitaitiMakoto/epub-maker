require 'rake/testtask'
require 'rake/clean'
require 'yard'
require "rubygems/tasks"
  require "open-uri"

task :default => :test

CLEAN.include 'README.html'

VALID_EPUB = "test/fixtures/accessible_epub_3.epub"
file VALID_EPUB do |t|
  File.write t.name, URI("https://github.com/IDPF/epub3-samples/releases/download/20170606/accessible_epub_3.epub").read
end
Rake::TestTask.new
task test: VALID_EPUB
YARD::Rake::YardocTask.new
Gem::Tasks.new
