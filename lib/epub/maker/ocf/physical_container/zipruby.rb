require 'epub/ocf/physical_container/zipruby'

module EPUB
  class OCF
    class PhysicalContainer
      class Zipruby < self
        def write(path_name, content)
          if @archive
            @archive.add_or_replace_buffer path_name, content
          else
            open {|container| container.save(path_name, content)}
          end
        end
      end
    end
  end
end
