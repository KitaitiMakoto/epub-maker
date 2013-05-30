require 'epub/publication/package'

module EPUB
  module Publication
    class Package
      def to_xml
        Nokogiri::XML::Builder.new {|xml|
          attrs = {
            'version'           => '3.0',
            'xmlns'             => EPUB::NAMESPACES['opf'],
            'unique-identifier' => unique_identifier.id
          }
          [
           ['dir', dir],
           ['id', id],
           ['xml:lang', xml_lang],
           ['prefix', prefix.reduce('') {|attr, (pfx, iri)| [attr, [pfx, iri].join(':')].join(' ')}]
          ].each do |(name, value)|
            next if value.nil? or value.empty?
            attrs[name] = value
          end
          xml.package_(attrs) do
            (EPUB::Publication::Package::CONTENT_MODELS - [:guide]).each do |model|
              __send__(model).to_xml_fragment xml
            end
          end
        }.to_xml
      end

      def make
        (CONTENT_MODELS - [:guide]).each do |model|
          klass = self.class.const_get(model.to_s.capitalize)
          obj = klass.new
          __send__ "#{model}=", obj
        end
        yield self if block_given?
        self
      end

      def make_metadata
        self.metadata = Metadata.new
        metadata.make do
          yield metadata if block_given?
        end
        metadata
      end

      def save(archive)
        archive.add_buffer book.rootfile_path, to_xml
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

        def make
          yield self if block_given?
          unless unique_identifier
            if identifiers.empty?
              identifier = DCMES.new
              identifier.id = 'pub-id'
              identifier.content = UUID.create.to_s
              self.dc_identifiers << identifier
              self.unique_identifier = identifier
            else
              self.unique_identifier = identifiers.first
            end
          end
          self
        end

        def to_xml_fragment(xml)
          xml.metadata_('xmlns:dc' => EPUB::NAMESPACES['dc']) {
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
          node = xml.manifest_ {
            items.each do |item|
              item_node = xml.item_
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
          node = xml.spine_ {
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
          xml.bindings_ {
            media_types.each do |media_type|
              media_type_node = xml.mediaType
              to_xml_attribute media_type_node, media_type, [:media_type]
              media_type_node['handler'] = media_type.handler.id if media_type.handler && media_type.handler.id
            end
          }
        end
      end
    end
  end

  class Maker
    module Publication
      class Package
        attr_reader :package

        def initialize
          @package = EPUB::Publication::Package.new
        end

        def dc_titles
          package.metadata.dc_titles
        end
      end
    end
  end
end
