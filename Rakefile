require 'rake/testtask'
require 'rake/clean'
require 'yard'
require "rubygems/tasks"

task :default => :test

CLEAN.include 'README.html'

Rake::TestTask.new
YARD::Rake::YardocTask.new
Gem::Tasks.new
