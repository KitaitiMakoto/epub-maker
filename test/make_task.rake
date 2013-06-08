require_relative 'helper'
require 'epub/maker/rake/make_task'

EPUB::Maker::Rake::MakeTask.new do |task|
  # task.title = 'Sample eBook'
  # task.language = 'ja'
  # task.contributors = ['KITAITI Makoto']

  dir = Pathname(__dir__) + 'fixtures' + 'book'
  Pathname.glob("#{dir}/OPS/*.xhtml").each do |path|
    task.files << path.to_path
    task.map[path.to_path] = path.relative_path_from(dir).to_path
  end

require 'pp'
pp task.files
pp task.map

  task.base_dir = File.join(__dir__, 'fixtures', 'book')
  task.files = FileList["#{task.base_dir}/OPS/*"].sort

pp task.build_map

end
