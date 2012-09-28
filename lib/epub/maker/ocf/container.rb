require 'nokogiri'
require 'epub/ocf/container'

module EPUB
  module Maker
    module OCF
      module Container
        def to_xml
          Nokogiri::XML::Builder.new do |xml|
            xml.container('xmlns' => EPUB::NAMESPACES['ocf'], 'version' => '1.0') {
              xml.rootfiles {
                rootfiles.each do |rootfile|
                  xml.rootfile('full-path' => rootfile.full_path, 'media-type' => rootfile.media_type)
                end
              }
            }
          end.to_xml
        end
      end
    end
  end

  class OCF
    class Container
      include Maker::OCF::Container
    end
  end
end
