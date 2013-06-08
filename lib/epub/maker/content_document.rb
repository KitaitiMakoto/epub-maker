require 'epub/content_document'

module EPUB
  module ContentDocument
    class Navigation
      def to_xml(options={:encoding => 'UTF-8'})
        Nokogiri::XML::Builder.new(options) {|xml|
          xml.html('xmlns' => EPUB::NAMESPACES['xhtml'], 'xmlns:epub' => EPUB::NAMESPACES['epub']) {
            xml.head {
              xml.title_ 'Table of Contents'
            }
            xml.body {
              navigations.each do |navigation|
                xml.nav_('epub:type' => navigation.type) {
                  unless navigation.items.empty?
                    xml.ol {
                      navigation.items.each do |item|
                        xml.li {
                          if item.href
                            xml.a item.text, 'href' => item.href
                          else
                            xml.span_ item.text
                          end
                        }
                      end
                    }
                  end
                }
              end
            }
          }
        }.to_xml
      end
    end
  end
end
