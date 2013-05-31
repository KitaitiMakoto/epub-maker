require 'forwardable'
require 'pathname'
require 'pathname/common_prefix'
require 'fileutils'
require 'tmpdir'
require 'time'
require 'uuid'
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

      def make_from_package_document(package_document_path, root_dir=nil)
        maker = new
        maker.package_document_path = package_document_path
        maker.root_dir = root_dir
        FileUtils.cp File.expand_path('../../../templates/template.epub', __FILE__), maker.output_path.to_s
        Zip::Archive.open maker.output_path.to_s do |archive|
          archive.add_buffer 'META-INF/container.xml', maker.container.to_xml
          archive.add_file maker.rootfile_path.to_s, maker.package_document_path.to_s
          maker.package.manifest.items.each do |item|
            path_on_container = maker.base_dir + item.href.to_s
            path_on_file_system = maker.root_dir + path_on_container
            archive.add_file path_on_container.to_s, path_on_file_system.to_s
          end
        end
      end

      def make_from_directory(dir)
        dir = Pathname(dir)

        container_dir = dir + EPUB::Parser::OCF::DIRECTORY
        container_file = container_dir + 'container.xml'
        ocf_parser = Parser::OCF.new(nil)
        container = ocf_parser.parse_container(container_file.read)

        opf_file = dir + container.rootfile.full_path
        publication_parser = Parser::Publication.new(opf_file.read, opf_file.to_s)
        package = publication_parser.parse

        files = package.manifest.items.select {|item| item.href.relative?}
        target_file = dir.sub_ext('.epub')
        template_file = Pathname(File.expand_path('../../../templates/template.epub', __FILE__))
        FileUtils.copy_file template_file, target_file.to_s

        Zip::Archive.open target_file.to_s do |zip|
          rootfile = Pathname(container.rootfile.full_path)
          rootdir = dir + rootfile.dirname
          zip.add_file File.join('META-INF', 'container.xml'), container_file.to_s
          zip.add_file rootfile.to_s, opf_file.to_s
          files.each do |file|
            puts "add_file #{file.href} #{rootdir+file.href}"
            zip.add_file file.href.to_s, (rootdir+file.href.to_s).to_s
          end
        end
      end
    end

    attr_reader :package_document_path
    attr_writer :container, :package, :root_dir, :base_dir, :output_path

    # @todo Add "mimetype" file without compression
    # @todo Add option whether mv blocks or not when file locked already
    # @todo Timeout when file shared-locked long time
    def make(path)
      book = EPUB::Book.new
      Dir.mktmpdir 'epub-maker' do |dir|
        temp_path = File.join(dir, File.basename(path))
        copy File.join(__dir__, '..', '..', 'templates', 'template.epub'), temp_path

        Zip::Archive.open temp_path do |archive|
          yield book if block_given?
          book.save archive
        end

        File.open path, 'wb' do |file|
          raise "Other process is locking #{path}" unless file.flock File::LOCK_SH|File::LOCK_NB
          move temp_path, path
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
