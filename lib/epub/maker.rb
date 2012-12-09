require 'forwardable'
require 'pathname'
require 'pathname/common_prefix'
require 'fileutils'
require 'epub/parser'
require "epub/maker/version"
require 'epub/maker/ocf'

module EPUB
  module Constants
    MIME_TYPE = 'application/epub+zip'
  end

  class Maker
    class << self
      def make(*args, &block)
        new.make(&block)
      end

      def make_from_package_document(package_document_path, root_dir=nil)
        path = Pathname.new(package_document_path)
        package = EPUB::Parser::Publication.new(path.read, path.to_path).parse
        root_dir = root_dir ? Pathname.new(root_dir)
                            : path.common_prefix(package.manifest.items.collect {|item| item.href.to_s})
        base_dir = path.dirname.relative_path_from(root_dir)
        base_dir = Pathname.new('') if base_dir.to_s == '.'
        rootfile_path = path.relative_path_from(root_dir)
        container = OCF::Container.new
        rootfile = OCF::Container::Rootfile.new(rootfile_path)
        container.rootfiles << rootfile
        filename = root_dir.to_s + '.epub'
        FileUtils::Verbose.cp File.expand_path('../../../templates/template.epub', __FILE__), filename
        Zip::Archive.open filename do |archive|
          archive.add_buffer 'META-INF/container.xml', container.to_xml
          archive.add_file rootfile_path.to_s, path.to_s
          package.manifest.items.each do |item|
            path_on_container = base_dir + item.href.to_s
            path_on_file_system = root_dir + path_on_container
            archive.add_file path_on_container.to_s, path_on_file_system.to_s
          end
        end
      end

      def make_from_directory(dir)
        dir = Pathname(dir)

        container_file = dir + 'META-INF' + 'container.xml'
        ocf_parser = Parser::OCF.new(nil)
        container = ocf_parser.parse_container(container_file.read)

        opf_file = dir+container.rootfile.full_path
        publication_parser = Parser::Publication.new(opf_file.read, opf_file.to_s)
        package = publication_parser.parse

        files = package.manifest.items.select {|item| item.href.relative?}
        target_file = dir.sub_ext('.epub')
        template_file = Pathname(File.expand_path('../../../templates/template.epub', __FILE__))
        FileUtils.copy_file template_file, target_file.to_s

        Zip::Archive.open target_file.to_s do |zip|
          rootfile = Pathname(container.rootfile.full_path)
          rootdir = rootfile.dirname
          zip.add_file File.join('META-INF', 'container.xml'), container_file.to_s
          zip.add_file rootfile.to_s, opf_file.to_s
          files.each do |file|
            zip.add_file (rootdir+file.href.to_s).to_s, file.href.to_s
          end
        end
      end
    end

    attr_reader :container, :package

    def initialize
      @container = OCF::Container.new
      @package = Publication::Package.new
    end

    def make
      yield self

      validate
      build_xml
      archive
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
end

class Pathname
  def write(str)
    open 'w' do |file|
      file << str
    end
  end
end
