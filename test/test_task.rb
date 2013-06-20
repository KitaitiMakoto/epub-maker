# -*- coding: utf-8 -*-
require_relative 'helper'
require 'epub/maker/task'

class TestTask < Test::Unit::TestCase
  def setup
    @base_dir = File.join(__dir__, 'fixtures', 'book')
    @epub_name = File.join(__dir__, 'fixtures', 'book.epub')
    FileUtils::Verbose.rm @epub_name if File.exist? @epub_name

    @task = EPUB::Maker::Task.new @epub_name do |task|
      task.titles = ['EPUB Maker Rake Example'] # temporary

      task.base_dir = @base_dir

      task.rootfile = "#{@base_dir}/OPS/ルートファイル.opf"
      task.make_rootfiles = true

      task.resources.include "#{@base_dir}/**/*"
      task.resources.exclude {|entry| ! File.file? entry}
      task.resources.exclude /\.opf/
      task.resources.exclude /META\-INF/

      task.navs.include 'OPS/nav.xhtml'
      task.media_types = {"#{@base_dir}/OPS/slideshow.xml" => 'application/x-demo-slideshow'}

      task.spine = task.resources.dup
      task.spine.exclude /OPS\/impl\.xhtml\z/
      task.spine.exclude /\.xml\z/

      task.bindings = {'application/x-demo-slideshow' => "#{@base_dir}/OPS/impl.xhtml"}

      task.files = task.rootfiles + task.resources
      task.files.include "#{@base_dir}/META-INF/*.xml"
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
      File.join(@base_dir, 'OPS/impl.xhtml')          => 'OPS/impl.xhtml',
      File.join(@base_dir, 'OPS/slideshow.xml')       => 'OPS/slideshow.xml'
    }

    assert_equal expected, @task.file_map
  end
end
