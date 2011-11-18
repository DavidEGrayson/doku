require 'rubygems'
begin
  require 'rake'
  require 'jeweler'
  require 'rspec/core'
  require 'rspec/core/rake_task'
  require 'yard'
rescue LoadError => e
  $stderr.puts "Run `gem install bundler && bundle install` to install missing gems."
  exit 1
end

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "doku"
  gem.homepage = "http://github.com/DavidEGrayson/doku"
  gem.license = "MIT"
  gem.files = %w{.document *.txt *.rdoc VERSION
    Gemfile Rakefile
    lib/doku.rb
    lib/doku/*.rb
    spec/*.rb
  }

  gem.summary = "Ruby library for solving sudoku, hexadoku, and similar puzzles."
  gem.description = <<END
This gem allows you to represent Sudoku-like puzzles
(Sudoku, Hexadoku, and Hexamurai) as objects and find
solutions for them.

This gem contains a reusable, pure ruby implementation of the
Dancing Links algorithm by Donald Knuth.
END
  gem.email = "davidegrayson@gmail.com"
  gem.authors = ["David Grayson"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

YARD::Rake::YardocTask.new do |t|
  t.files   = %w{lib/**/*.rb}
  t.options = %w{}
end

task :default => :spec
