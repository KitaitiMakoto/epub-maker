require 'tmpdir'
require 'epub/ocf/physical_container'
[
  [:ArchiveZip, 'archive_zip'],
  [:Zipruby, 'zipruby']
].each do |(class_name, feature_name)|
  if EPUB::OCF::PhysicalContainer.const_defined? class_name
    require "epub/maker/ocf/physical_container/#{feature_name}"
  end
end

module EPUB
  class OCF
    class PhysicalContainer
      class << self
        def write(container_path, path_name, content)
          open(container_path) {|container|
            container.write(path_name, content)
          }
        end

        def save(container_path, path_name, content)
          warn "EPUB::OCF::PhysicalContainer.#{__method__} is deprecated. Use .write instead"
          write(container_path, path_name, content)
        end
      end
    end
  end
end
