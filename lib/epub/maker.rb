require "epub/maker/version"
require 'pathname'
require 'pathname/common_prefix'
require 'fileutils'
require 'epub/parser'

module EPUB
  module Constants
    MIME_TYPE = 'application/epub+zip'
  end

  class Maker
    class << self
      def make_from_directory(dir)
        dir = Pathname(dir)

        container_file = dir + 'META-INF' + 'container.xml'
        ocf_parser = Parser::OCF.new(nil)
        container = ocf_parser.parse_container(container_file.read)

        opf_file = dir+container.rootfile.full_path
        publication_parser = Parser::Publication.new(opf_file.read, opf_file.to_s)
        package = publication_parser.parse

        files = package.manifest.items.select {|item| item.iri.relative?}
        target_file = dir.sub_ext('.epub')
        template_file = Pathname(File.expand_path('../../../templates/template.epub', __FILE__))
        FileUtils.copy_file template_file, target_file.to_s

        Zip::Archive.open target_file.to_s do |zip|
          rootfile = Pathname(container.rootfile.full_path)
          rootdir = rootfile.dirname
          zip.add_file File.join('META-INF', 'container.xml'), container_file.to_s
          zip.add_file rootfile.to_s, opf_file.to_s
          files.each do |file|
            zip.add_file (rootdir+file.href).to_s, file.iri.to_s
          end
        end
      end
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
