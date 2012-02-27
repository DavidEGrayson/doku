# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "doku"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Grayson"]
  s.date = "2012-02-27"
  s.description = "This gem allows you to represent Sudoku-like puzzles\n(Sudoku, Hexadoku, and Hexamurai) as objects and find\nsolutions for them.\n\nThis gem contains a reusable, pure ruby implementation of the\nDancing Links algorithm by Donald Knuth.\n"
  s.email = "davidegrayson@gmail.com"
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "Gemfile",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/doku.rb",
    "lib/doku/dancing_links.rb",
    "lib/doku/grid.rb",
    "lib/doku/hexadoku.rb",
    "lib/doku/hexamurai.rb",
    "lib/doku/puzzle.rb",
    "lib/doku/solver.rb",
    "lib/doku/sudoku.rb",
    "spec/dancing_links_spec.rb",
    "spec/hexadoku_spec.rb",
    "spec/hexamurai_spec.rb",
    "spec/puzzle_spec.rb",
    "spec/solution_spec.rb",
    "spec/spec_helper.rb",
    "spec/sudoku_spec.rb",
    "spec/watch.rb"
  ]
  s.homepage = "http://github.com/DavidEGrayson/doku"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Ruby library for solving sudoku, hexadoku, and similar puzzles."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<backports>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<watchr>, [">= 0"])
      s.add_development_dependency(%q<ruby-prof>, [">= 0"])
      s.add_development_dependency(%q<linecache19>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug-base19>, [">= 0.11.26"])
      s.add_development_dependency(%q<ruby-debug19>, [">= 0"])
    else
      s.add_dependency(%q<backports>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<watchr>, [">= 0"])
      s.add_dependency(%q<ruby-prof>, [">= 0"])
      s.add_dependency(%q<linecache19>, [">= 0"])
      s.add_dependency(%q<ruby-debug-base19>, [">= 0.11.26"])
      s.add_dependency(%q<ruby-debug19>, [">= 0"])
    end
  else
    s.add_dependency(%q<backports>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<watchr>, [">= 0"])
    s.add_dependency(%q<ruby-prof>, [">= 0"])
    s.add_dependency(%q<linecache19>, [">= 0"])
    s.add_dependency(%q<ruby-debug-base19>, [">= 0.11.26"])
    s.add_dependency(%q<ruby-debug19>, [">= 0"])
  end
end

