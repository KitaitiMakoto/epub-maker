require 'forwardable'
require 'pathname'
require 'pathname/common_prefix'
require 'fileutils'
require 'tmpdir'
require 'time'
require 'uuid'
require 'archive/zip'
require 'epub/book'
require 'epub/parser'
require "epub/maker/version"
require 'epub/maker/ocf'
require 'epub/maker/publication'
require 'epub/maker/content_document'

module EPUB
  module Constants
    MIME_TYPE = 'application/epub+zip'
  end

  class Maker
    include ($VERBOSE ? ::FileUtils::Verbose : ::FileUtils)

    class << self
      def make(path, &block)
        new.make(path, &block)
      end
    end

    attr_reader :package_document_path
    attr_writer :container, :package, :root_dir, :base_dir, :output_path

    # @param path [Pathname|#to_path|String]
    # @todo Add option whether mv blocks or not when file locked already
    # @todo Timeout when file shared-locked long time
    def make(path)
      path = Pathname(path) unless path.kind_of? Pathname
      book = EPUB::Book.new
      Dir.mktmpdir 'epub-maker' do |dir|
        dir = Pathname(dir)
        temp_path = dir + path.basename
        mimetype = dir + 'mimetype'
        mimetype.write EPUB::MIME_TYPE
        Archive::Zip.open temp_path.to_path, :w do |archive|
          file = Archive::Zip::Entry.from_file(mimetype.to_path, compression_codec: Archive::Zip::Codec::Store)
          archive.add_entry file
        end

        Zip::Archive.open temp_path.to_path do |archive|
          yield book if block_given?
          book.save archive
        end

        path.open 'wb' do |file|
          raise "Other process is locking #{path}" unless file.flock File::LOCK_SH|File::LOCK_NB
          move temp_path.to_path, path.to_path
        end
      end
      book

      # validate
      # build_xml
      # archive
    end

    def package_document_path=(path)
      @package_document_path = path.kind_of?(Pathname) ? path : Pathname.new(path)
    end

    def container
      @container ||= begin
        c = OCF::Container.new
        c.rootfiles << rootfile
        c
      end
    end

    def package
      @package ||= EPUB::Parser::Publication.new(package_document_path.read, package_document_path.to_path).parse
    end

    def root_dir
      @root_dir ||= package_document_path.common_prefix(package.manifest.items.collect {|item| item.href.to_s})
    end

    def root_dir=(path)
      @root_dir = path.kind_of?(Pathname) ? path : Pathname.new(path)
    end

    def base_dir
      bd = package_document_path.dirname.relative_path_from(root_dir)
      bd.to_path == '.' ? Pathname.new('') : bd
    end

    def rootfile_path
      package_document_path.relative_path_from(root_dir)
    end

    def rootfile
      OCF::Container::Rootfile.new(rootfile_path)
    end

    def output_path
      @output_path ||= Pathname.new(root_dir.to_s + '.epub')
    end

    def title=(title)
      unless title.kind_of?(EPUB::Publication::Package::Metadata::Title)
        title_content = title.to_s
        title = EPUB::Publication::Package::Metadata::Title.new
        # title.display_seq = 
        title.content = title_content
      end
      package.metadata.dc_titles.unshift title # metas which refines titles are created after yielding block after the order of package.dc_titles
    end
  end

  def make_ocf
    self.ocf = OCF.new
    ocf.make do |ocf|
      yield ocf if block_given?
    end
    ocf
  end

  def make_package
    self.package = Publication::Package.new
    package.make do |package|
      yield package if block_given?
    end
    package
  end

  # @param archive [Zip::Archive]
  def save(archive)
    ocf.save archive
    package.save archive
    resources.each do |item|
      item.save archive
    end
  end
end

class Pathname
  def write(str)
    open 'w' do |file|
      file << str
    end
  end
end
