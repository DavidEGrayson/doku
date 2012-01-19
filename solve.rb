#!/usr/bin/env ruby

$LOAD_PATH << 'lib'
require 'doku'

if ARGV.size != 1
  puts "Usage: solve.rb path_to_puzzle.rb"
  puts "Example: solve.rb puzzles/elektor/2011-11.rb"
  puts "The .rb extension in the parameter is optional."
  exit 1
end

require_relative ARGV[0]

$puzzle.solutions.each do |s|
  puts s + "\n"
end
