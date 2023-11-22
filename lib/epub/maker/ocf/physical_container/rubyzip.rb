require "epub/ocf/physical_container/rubyzip"

module EPUB
  class OCF
    class PhysicalContainer
      class Rubyzip < self
        def write(path_name, content, mtime: nil)
          if @archive
            @archive.remove path_name
            @archive.get_output_stream(path_name, nil, nil, nil, nil, nil, nil, nil, mtime) {|f| f.write content}
            @archive.commit
          else
            open {|container| container.write(path_name, content, mtime: mtime)}
          end
        end
      end
    end
  end
end
