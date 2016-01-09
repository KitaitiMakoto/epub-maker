require 'epub/ocf'
require 'epub/maker/ocf/physical_container'

# @todo Use refinement
module EPUB
  class OCF
    DIRECTORY = 'META-INF'

    def make
      yield self if block_given?
      self
    end

    def save
      book.container_adapter.save book.epub_file, File.join(DIRECTORY, Container::FILE), self.container.to_xml if self.container
    end

    # @overload make_container
    #   @return [Container]
    # @overload make_container
    #   @return [Container]
    #   @yield [container] if block given
    #   @yieldparam [Container]
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

      # @option full_path [String|nil] full path to package document file in container such like "OPS/content.opf"
      # @option media_type [String] media type
      # @yield [Rootfile] rootfile
      def make_rootfile(full_path: nil, media_type: EPUB::MediaType::ROOTFILE)
        rootfile = Rootfile.new(full_path, media_type)
        @rootfiles << rootfile
        yield rootfile if block_given?
        rootfile
      end
    end
  end
end
