require 'epub/ocf/container'

module EPUB
  class OCF
    class Container
      def to_xml
        Nokogiri::XML::Builder.new {|xml|
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
    end
  end
end
