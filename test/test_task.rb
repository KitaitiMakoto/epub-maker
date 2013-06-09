# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/maker/task'

class TestTask < Test::Unit::TestCase
  def setup
    @base_dir = File.join(__dir__, 'fixtures', 'book')
    @epub_name = File.join(__dir__, 'fixtures', 'book.epub')
    FileUtils::Verbose.rm @epub_name if File.exist? @epub_name

    @task = EPUB::Maker::Task.new @epub_name do |task|
      task.base_dir = @base_dir

      task.files.include "#{@base_dir}/**/*"
      task.files.exclude {|entry| ! File.file? entry}

      task.rootfile = "#{@base_dir}/OPS/ルートファイル.opf"
      task.make_rootfiles = true

      task.resources = task.files.dup
      task.resources.exclude /\.opf/
      task.resources.exclude /META\-INF/
    end
  end

  def test_execute
    Rake::Task[:epub].execute
    assert_path_exist @epub_name
    assert_valid_epub @epub_name
  end

  def test_file_map
    expected = {
      File.join(@base_dir, 'META-INF/container.xml')  => 'META-INF/container.xml',
      File.join(@base_dir, 'OPS/ルートファイル.opf')  => 'OPS/ルートファイル.opf',
      File.join(@base_dir, 'OPS/item-1.xhtml')        => 'OPS/item-1.xhtml',
      File.join(@base_dir, 'OPS/item-2.xhtml')        => 'OPS/item-2.xhtml',
      File.join(@base_dir, 'OPS/nav.xhtml')           => 'OPS/nav.xhtml',
      File.join(@base_dir, 'OPS/slideshow.xml')       => 'OPS/slideshow.xml'
    }

    assert_equal expected, @task.file_map
  end

  def test_when_rootfile_is_given_to_map_then_read_from_file
    pend
  end

  def test_when_rootfie_is_not_given_to_map_then_build_xml
    pend
  end

  def test_title
    pend
  end
end
