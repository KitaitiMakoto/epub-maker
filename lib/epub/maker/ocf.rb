require 'epub/ocf/container'

# @todo Use refinement
module EPUB
  class OCF
    DIRECTORY = 'META-INF'

    def make
      yield self if block_given?
      self
    end

    # @param archive [Zip::Archive] path to archive file
    def save(archive)
      self.container.save archive if self.container
    end

    def make_container
      self.container = Container.new
      yield container if block_given?
      container
    end

    class Container
      def to_xml(options={:encoding => 'UTF-8'})
        Nokogiri::XML::Builder.new(options) {|xml|
          xml.container('xmlns' => EPUB::NAMESPACES['ocf'], 'version' => '1.0') {
            xml.rootfiles {
              rootfiles.each do |rootfile|
                xml.rootfile('full-path' => rootfile.full_path,
                             'media-type' => rootfile.media_type)
              end
            }
          }
        }.to_xml
      end

      # @param archive [Zip::Archive]
      def save(archive)
        archive.add_buffer File.join(DIRECTORY, Container::FILE), to_xml
      end

      # @option full_path [String|nil] full path to package document file in container such like "OPS/content.opf"
      # @option media_type [String] media type
      # @yield [Rootfile] rootfile
      def make_rootfile(full_path: nil, media_type: MediaType::ROOTFILE)
        rootfile = Rootfile.new(full_path, media_type)
        @rootfiles << rootfile
        yield rootfile if block_given?
        rootfile
      end
    end
  end
end
