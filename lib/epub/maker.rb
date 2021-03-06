require 'English'
require 'pathname'
require 'pathname/common_prefix'
require 'fileutils'
require 'tmpdir'
require 'time'
require 'uuid'
require 'archive/zip'
require 'epub'
require 'epub/constants'
require 'epub/book'
require 'epub/parser'
require "epub/maker/version"
require 'epub/maker/ocf'
require 'epub/maker/publication'
require 'epub/maker/content_document'

module EPUB
  module Maker
    class Error < StandardError; end

    class << self
      # @param path [Pathname|#to_path|String]
      # @todo Add option whether mv blocks or not when file locked already
      # @todo Timeout when file shared-locked long time
      def make(path)
        path = Pathname(path) unless path.kind_of? Pathname
        book = EPUB::Book.new
        dir = Pathname.mktmpdir 'epub-maker'
        temp_path = dir/path.basename
        mimetype = dir/'mimetype'
        mimetype.write EPUB::MediaType::EPUB
        Archive::Zip.open temp_path.to_path, :w do |archive|
          file = Archive::Zip::Entry.from_file(mimetype.to_path, compression_codec: Archive::Zip::Codec::Store)
          archive.add_entry file
        end

        book.epub_file = temp_path.to_path
        yield book if block_given?
        book.save

        path.open 'wb' do |file|
          raise Error, "File locked by other process: #{path}" unless file.flock File::LOCK_SH|File::LOCK_NB
          ($VERBOSE ? ::FileUtils::Verbose : ::FileUtils).move temp_path.to_path, path.to_path
        end
        dir.remove_entry_secure
        book.epub_file = path.to_path
        book

        # validate
        # build_xml
        # archive
      rescue => error
        backtrace = error.backtrace
        error = error.exception([
                  error.message,
                  "[#{self}]Working directory remained at: #{dir}"
                ].join($RS))
        backtrace.unshift("#{__FILE__}:#{__LINE__}:in `rescue in #{__method__}'")
        error.set_backtrace backtrace
        raise error
      end
    end
  end

  module Book::Features
    def make_ocf
      self.ocf = OCF.new
      ocf.make do |ocf|
        yield ocf if block_given?
      end
      ocf
    end

    def make_package
      package = Publication::Package.new
      package.book = self
      package.make do |package|
        yield package if block_given?
      end
      no_package_rootfile = rootfiles.find {|rf| rf.package.nil?}
      no_package_rootfile.package = package if no_package_rootfile
      package
    end

    def save
      ocf.save
      packages.each(&:save)
      resources.each(&:save)
    end
  end
end

class Pathname
  class << self
    # @overload mktmpdir(prefix_suffix=nil, tmpdir=nil)
    #   @param prefix_suffix [String|nil] see Dir.mktmpdir
    #   @param tmpdir [String|nil] see Dir.mktmpdir
    #   @return [Pathname] path to temporary directory
    # @overload mktmpdir(prefix_suffix=nil, tmpdir=nil)
    #   @param prefix_suffix [String|nil] see Dir.mktmpdir
    #   @param tmpdir [String|nil] see Dir.mktmpdir
    #   @yieldparam dir [Pathname] path to temporary directory
    #   @return value of given block
    def mktmpdir(prefix_suffix=nil, tmpdir=nil)
      if block_given?
        Dir.mktmpdir prefix_suffix, tmpdir do |dir|
          yield new(dir)
        end
      else
        new(Dir.mktmpdir(prefix_suffix, tmpdir))
      end
    end
  end

  def remove_entry_secure
    FileUtils.remove_entry_secure to_path
  end

  unless method_defined? :/
    alias / +
  end
end
