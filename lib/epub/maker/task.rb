require 'rake'
require 'rake/tasklib'
require 'epub/maker'

module EPUB
  module Maker
    class Task < ::Rake::TaskLib
      DUMMY_ROOT_IRI = Addressable::URI.parse('dummy:///').freeze

      attr_accessor :target, :base_dir, :files, :file_map_proc,
                    :container, :rootfiles, :make_rootfiles, :package_direction, :language,
                    :titles, :contributors,
                    :resources, :navs, :cover_image, :media_types,
                    :spine,
                    :bindings

      # @param name [String] EPUB file name
      def initialize(name)
        init name
        yield self if block_given?
        define
      end

      def init(name)
        @target = :epub
        @name = name
        @files = FileList.new
        @base_dir = Dir.pwd
        @rootfiles = FileList.new
        @make_rootfiles = false
        @resources = FileList.new
        @package_direction = 'rtl'
        @language = 'en'
        @file_map = {}
        @file_map_proc = -> (src_name) {src_name.sub("#{@base_dir.sub(/\/\z/, '')}/", '')}
        @navs = FileList.new
        @media_types = {}
        @spine = FileList.new
        @bindings = {}
      end

      def define
        desc 'Make EPUB file'
        task @target do
          EPUB::Maker.make @name do |book|
            book.make_ocf do |ocf|
              if container
                ocf.container = EPUB::Parser::OCF.new(nil).parse_container(File.read(container))
              else
                raise 'Set at least one rootfile' if rootfiles.empty?
                ocf.make_container do |container|
                  rootfiles.each do |rootfile|
                    container.make_rootfile full_path: Addressable::URI.parse(file_map[rootfile])
                  end
                end
              end
            end

            if make_rootfiles
              book.make_package do |package|
                package.dir = package_direction

                package.make_metadata do |metadata|
                  metadata.title = @titles.first
                  metadata.language = language
                end

                package.make_manifest do |manifest|
                  rootfile_absolute_path = DUMMY_ROOT_IRI + package.book.ocf.container.rootfile.full_path
                  resources.each_with_index do |resource, index|
                    resource_absolute_iri = DUMMY_ROOT_IRI + file_map[resource]
                    manifest.make_item do |item|
                      item.id = "item-#{index + 1}"
                      item.href = resource_absolute_iri.route_from(rootfile_absolute_path)
                      item.media_type = detect_media_type(resource)
                      item.content_file = resource
                      item.properties << 'nav' if navs.include? item.entry_name
                      item.properties << 'scripted' unless Nokogiri.XML(open(resource)).search('script').empty?
                    end
                  end
                end

                package.make_spine do |spine|
                  @spine.each do |item_path|
                    entry_name = file_map[item_path]
                    spine.make_itemref do |itemref|
                      item = package.manifest.items.find {|i| i.entry_name == entry_name}
                      itemref.item = item if item
                      warn "missing item #{item_path}, referred by itemref" if itemref.item.nil?
                      itemref.linear = true # TODO: Make more customizable
                    end
                  end
                end

                if @bindings and !@bindings.empty?
                  package.make_bindings do |bindings|
                    @bindings.each_pair do |media_type, handler_path|
                      bindings.make_media_type do |mt|
                        mt.media_type = media_type
                        entry_name = file_map[handler_path]
                        mt.handler = package.manifest.items.find {|item| item.entry_name == entry_name}
                        warn "missing handler for #{media_type}" if mt.handler.nil?
                      end
                    end
                  end
                end
              end
            else
              raise 'No rootfile set' if @rootfiles.empty?
              rf = rootfiles.first
              book.package = EPUB::Parser::Publication.new(File.read(rf), file_map[rf]).parse
            end
          end
        end
      end

      def rootfile=(rootfile)
        rootfiles.unshift rootfile
        rootfile
      end

      def file_map(force_calculation=false)
        if force_calculation or @file_map.empty?
          @file_map.clear
          @files.each do |src_name|
            @file_map[src_name] = @file_map_proc[src_name]
          end
        end
        @file_map
      end

      # @param resource [String] resource path to detect media type
      # @return [String] detected media type
      def detect_media_type(resource)
        media_types[resource] ||
          case File.extname(resource)
          when '.xhtml', '.html' then 'application/xhtml+xml'
          end
      end
    end
  end
end
