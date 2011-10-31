require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems."
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "doku"
  gem.homepage = "http://github.com/DavidEGrayson/doku"
  gem.license = "MIT"
  gem.files = %w{.document *.txt *.rdoc VERSION
    Gemfile Rakefile
    lib/*.rb
  } +
    FileList['spec/*.rb'] +
    FileList['lib/ruby-usb-pro/*.rb'] +
    FileList['lib/ruby-usb-pro/**/*.rb']

  gem.summary = "Ruby library for solving sudoku, hexadoku, and similar puzzles."
  gem.description = <<END
This gem allows you to represent Sudoku-like puzzles
(Sudoku, Hexadoku, and Hexamurai) as objects and find
solutions for them.

This gem contains a reusable implementation of the Dancing Links
algorithm by Donald Knuth.
END
  gem.email = "davidegrayson@gmail.com"
  gem.authors = ["David Grayson"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = %w{lib/**/*.rb}
  t.options = %w{}
end

task :default => :spec
