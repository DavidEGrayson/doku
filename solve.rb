#!/usr/bin/env ruby

if ARGV.size != 1
  puts "Usage: solve.rb path_to_puzzle.rb"
  puts "Example: solve.rb puzzles/elektor/2011-11.rb"
  puts "The .rb extension in the parameter is optional."
  exit 1
end

require_relative 'sudoku'
require_relative 'hexadoku'
require_relative ARGV[0]

puts $puzzle.solve
