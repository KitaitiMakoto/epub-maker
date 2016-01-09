require 'epub/ocf/physical_container/archive_zip'

module EPUB
  class OCF
    class PhysicalContainer
      class ArchiveZip < self
        def save(path_name, content)
          ::Dir.mktmpdir do |dir|
            path = ::File.join(dir, ::File.basename(path_name))
            ::File.write path, content
            Archive::Zip.archive @container_path, path, path_prefix: ::File.dirname(path_name)
          end
        end
      end
    end
  end
end
