require 'epub/publication/package'

module EPUB
  module Publication
    class Package
      def to_xml
        Nokogiri::XML::Builder.new {|xml|
          xml.package('version' => '3.0',
                      'unique-identifier' => unique_identifier.id,
                      'xmlns' => EPUB::NAMESPACES['opf']) do
            (EPUB::Publication::Package::CONTENT_MODELS - [:guide]).each do |model|
              __send__(model).to_xml_fragment xml
            end
          end
        }.to_xml
      end

      module ContentModel
        # @param [Nokogiri::XML::Builder::NodeBuilder] node
        # @param [Object] model
        # @param [Array<Symbol|String>] attributes names of attribute.
        def to_xml_attribute(node, model, attributes)
          attributes.each do |attr|
            val = model.__send__(attr)
            node[attr.to_s.gsub('_', '-')] = val if val
          end
        end
      end

      class Metadata
        include ContentModel

        def to_xml_fragment(xml)
          xml.metadata('xmlns:dc' => EPUB::NAMESPACES['dc']) {
            (DC_ELEMS - [:languages]).each do |elems|
              singular = elems[0..-2]
              __send__("dc_#{elems}").each do |elem|
                node = xml['dc'].__send__(singular, elem.content)
                to_xml_attribute node, elem, [:id, :dir]
                node['xml:lang'] = elem.lang if elem.lang
              end
            end
            languages.each do |language|
              xml.language language
            end

            metas.each do |meta|
              node = xml.meta(meta.content)
              to_xml_attribute node, meta, [:property, :id, :scheme]
              node['refines'] = "##{meta.refines.id}" if meta.refines
            end

            links.each do |link|
              node = xml.link
              to_xml_attribute node, link, [:href, :id, :media_type]
              node['rel'] = link.rel.join(' ') if link.rel
              node['refines'] = "##{link.refines.id}" if link.refines
            end
          }
        end
      end

      class Manifest
        include ContentModel

        def to_xml_fragment(xml)
          node = xml.manifest {
            items.each do |item|
              item_node = xml.item
              to_xml_attribute item_node, item, [:id, :href, :media_type, :media_overlay]
              item_node['properties'] = item.properties.join(' ') unless item.properties.empty?
              item_node['fallback'] = item.fallback.id if item.fallback
            end
          }
          to_xml_attribute node, self, [:id]
        end
      end

      class Spine
        include ContentModel

        def to_xml_fragment(xml)
          node = xml.spine {
            itemrefs.each do |itemref|
              itemref_node = xml.itemref
              to_xml_attribute itemref_node, itemref, [:idref, :id]
              itemref_node['linear'] = 'no' unless itemref.linear?
              itemref_node['properties'] = itemref.properties.join(' ') unless itemref.properties.empty?
            end
          }
          to_xml_attribute node, self, [:id, :toc, :page_progression_direction]
        end
      end

      class Bindings
        include ContentModel

        def to_xml_fragment(xml)
          xml.bindings {
            media_types.each do |media_type|
              media_type_node = xml.mediaType
              media_type_node['media_type'] = media_type.media_type if media_type.media_type
              media_type_node['handler'] = media_type.handler.id if media_type.handler && media_type.handler.id
            end
          }
        end
      end
    end
  end
end
