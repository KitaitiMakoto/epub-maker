require 'rake'
require 'rake/tasklib'
require 'epub/maker'

module EPUB
  class Maker
    class Task < ::Rake::TaskLib
      attr_accessor :target, :base_dir, :files, :file_map_proc,
                    :container, :rootfiles, :make_rootfiles, :package_direction, :language,
                    :titles, :contributors,
                    :resources, :navs, :cover_image,
                    :spine

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
        @package_direction = 'rtl'
        @language = 'en'
        @file_map = {}
        @file_map_proc = -> (src_name) {src_name.sub("#{@base_dir.sub(/\/\z/, '')}/", '')}
      end

      def define
        desc 'Make EPUB file'
        task @target do
          EPUB::Maker.make @name do |book|
            book.make_ocf do |ocf|
              if container
                ocf.container = EPUB::Parser::OCF.new(nil).parse_container(File.read(container))
              else
                raise 'Set at least one rootfile' if @rootfiles.empty?
                ocf.make_container do |container|
                  @rootfiles.each do |rootfile|
                    container.make_rootfile full_path: file_map[rootfile]
                  end
                end
              end
            end

            if make_rootfiles
              book.make_package do |package|
                package.dir = package_direction

                package.make_metadata do |metadata|
                  metadata.title = @title
                  metadata.language = language
                end

                package.make_manifest do |manifest|
                  
                end

                package.make_spine do |spine|
                  
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
    end
  end
end
