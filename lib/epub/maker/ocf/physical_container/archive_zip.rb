require 'epub/ocf/physical_container/archive_zip'

module EPUB
  class OCF
    class PhysicalContainer
      class ArchiveZip < self
        # @todo Write multiple files at once
        def write(path_name, content)
          ::Dir.mktmpdir do |dir|
            tmp_archive_path = ::File.join(dir, ::File.basename(@container_path) + '.tmp')
            ::File.open @container_path do |archive_in|
              ::File.open tmp_archive_path, 'w' do |archive_out|
                archive_out.binmode
                Archive::Zip.open archive_in, :r do |z_in|
                  Archive::Zip.open archive_out, :w do |z_out|
                    updated = false
                    z_in.each do |entry|
                      if entry.zip_path == path_name.force_encoding('ASCII-8BIT')
                        entry.file_data = StringIO.new(content)
                        updated = true
                      end
                      z_out << entry
                    end
                    unless updated
                      entry = Archive::Zip::Entry::File.new(path_name)
                      entry.file_data = StringIO.new(content)
                      z_out << entry
                    end
                  end
                end
              end
            end
            begin
              ::File.chmod 0666 & ~::File.umask, tmp_archive_path
              ::File.rename tmp_archive_path, @container_path
            rescue Errno::EACCES, Errno::EXDEV
              # In some cases on Windows, we fail to rename the file
              # but succeed to copy although I don't know why.
              # Race condition? I don't know. But no time to dig deeper.
              ::FileUtils.copy tmp_archive_path, @container_path
            end
          end
        end
      end
    end
  end
end
