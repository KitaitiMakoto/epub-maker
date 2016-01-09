require 'epub/ocf/physical_container/zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      class Zipruby < self
        def save(path_name, content)
          Zip::Archive.open @container_path do |archive|
            archive.add_or_replace_buffer path_name, content
          end
        end
      end
    end
  end
end
