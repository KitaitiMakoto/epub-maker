require 'epub/publication/package'

module EPUB
  module Publication
    class Package
      def to_xml(options={:encoding => 'UTF-8'})
        Nokogiri::XML::Builder.new(options) {|xml|
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
            (EPUB::Publication::Package::CONTENT_MODELS - [:bindings, :guide]).each do |model|
              __send__(model).to_xml_fragment xml
            end
            if bindings and !bindings.media_types.empty?
              bindings.to_xml_fragment xml
            end
          end
        }.to_xml
      end

      def make
        (CONTENT_MODELS - [:bindings, :guide]).each do |model|
          klass = self.class.const_get(model.to_s.capitalize)
          obj = klass.new
          __send__ "#{model}=", obj
        end
        yield self if block_given?
        self
      end

      def edit
        yield self if block_given?
        save
      end

      def make_metadata
        self.metadata = Metadata.new
        metadata.make do
          yield metadata if block_given?
        end
        metadata
      end

      def make_manifest
        self.manifest = Manifest.new
        manifest.make do
          yield manifest if block_given?
        end
        manifest
      end

      def make_spine
        self.spine = Spine.new
        spine.make do
          yield spine if block_given?
        end
        spine
      end

      def make_bindings
        self.bindings = Bindings.new
        bindings.make do
          yield bindings if block_given?
        end
        bindings
      end

      def save
        book.container_adapter.write book.epub_file, book.rootfile_path, to_xml
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

          unless metas.any? {|meta| meta.property == 'dcterms:modified'}
            modified = Meta.new
            modified.property = 'dcterms:modified'
            # modified.content = Time.now.utc.strftime('%FT%TZ')
            modified.content = Time.now.utc.iso8601
            self.metas << modified
          end

          self
        end

        def to_xml_fragment(xml)
          xml.metadata_('xmlns:dc' => EPUB::NAMESPACES['dc']) {
            (DC_ELEMS - [:languages]).each do |elems|
              singular = elems[0..-2]
              singular += 's' if elems == :rights
              singular += '_'
              __send__("dc_#{elems}").each do |elem|
                node = xml['dc'].__send__(singular, elem.content)
                to_xml_attribute node, elem, [:id, :dir]
                node['xml:lang'] = elem.lang if elem.lang
              end
            end

            languages.each do |language|
              xml['dc'].language language.content
            end

            metas.each do |meta|
              next unless meta.valid? # TODO: Consider whther to drop or keep as is
              node = xml.meta(meta.content)
              to_xml_attribute node, meta, [:property, :id, :scheme]
              node['refines'] = "##{meta.refines.id}" if meta.refines
            end

            links.each do |link|
              node = xml.link
              to_xml_attribute node, link, [:href, :id, :media_type]
              node['rel'] = link.rel.to_a.join(' ') if link.rel
              node['refines'] = "##{link.refines.id}" if link.refines
            end
          }
        end

        # Shortcut to set title from String
        # @param title [String]
        def title=(title)
          t = Title.new
          t.content = title
          self.dc_titles = [t]
          title
        end

        # Shortcut to set language from String
        # @param lang_code [String]
        def language=(lang_code)
          lang = DCMES.new
          lang.content = lang_code
          self.dc_languages = [lang]
          lang_code
        end

        # Shortcut to set one creator from String
        # @param name [String]
        def creator=(name)
          creator = DCMES.new
          creator.content = name
          self.dc_creators = [creator]
          name
        end

        class Meta
          def valid?
            property
          end
        end
      end

      class Manifest
        include ContentModel

        def make
          yield self if block_given?

          # @todo more careful
          unless items.any? &:nav?
            nav = Item.new
            nav.id = 'toc'
            nav.href = Addressable::URI.parse('nav.xhtml')
            nav.media_type = 'application/xhtml+xml'
            nav.properties << 'nav'

            nav_doc = ContentDocument::Navigation.new
            nav_doc.item = nav

            nav_nav = ContentDocument::Navigation::Navigation.new
            nav_nav.type = ContentDocument::Navigation::Navigation::Type::TOC
            nav_nav.items = items.select(&:xhtml?).map {|item; nav|
              nav = ContentDocument::Navigation::Item.new
              nav.item = item
              nav.href = item.href
              nav.text = File.basename(item.href.normalize.request_uri, '.*')
              nav
            }
            nav_doc.navigations << nav_nav

            nav.content = nav_doc.to_xml

            self << nav
          end

          self
        end

        # @return [Item]
        def make_item(options={})
          item = Item.new
          [:id, :href, :media_type, :properties, :media_overlay].each do |attr|
            next unless options.key? attr
            item.__send__ "#{attr}=", options[attr]
          end
          item.manifest = self
          yield item if block_given?
          self << item
          item
        end

        def to_xml_fragment(xml)
          node = xml.manifest_ {
            items.each do |item|
              item_node = xml.item_
              to_xml_attribute item_node, item, [:id, :href, :media_type, :media_overlay]
              item_node['properties'] = item.properties.to_a.join(' ') unless item.properties.empty?
              item_node['fallback'] = item.fallback.id if item.fallback
            end
          }
          to_xml_attribute node, self, [:id]
        end

        class Item
          attr_accessor :content, :content_file

          # @raise StandardError when no content nor content_file
          # @todo Don't read content from file when +content_file+ exists. If container adapter is Archive::Zip, it writes content to file twice.
          def save
            content_to_save =
              if content
                content
              elsif content_file
                File.read(content_file)
              else
                raise 'no content nor content_file'
              end
            book = manifest.package.book
            book.container_adapter.write book.epub_file, entry_name, content_to_save
          end

          # Save document into EPUB archive when block ended
          def edit
            yield if block_given?
            save
          end

          # Save document into EPUB archive at end of block
          # @yield [REXML::Document]
          def edit_with_rexml
            require 'rexml/document'
            doc = REXML::Document.new(read)
            yield doc if block_given?
            self.content = doc.to_s
            save
          end

          # Save document into EPUB archive at end of block
          # @yield [Nokgiri::XML::Document]
          def edit_with_nokogiri
            doc = Nokogiri.XML(read)
            yield doc if block_given?
            self.content = doc.to_xml
            save
          end
        end
      end

      class Spine
        include ContentModel

        def make
          yield self if block_given?
          self
        end

        def make_itemref
          itemref = Itemref.new
          self << itemref
          yield itemref if block_given?
          itemref
        end

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

        def make
          yield self if block_given?
          self
        end

        def make_media_type
          media_type = MediaType.new
          self << media_type
          yield media_type if block_given?
          media_type
        end

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
end
