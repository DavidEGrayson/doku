#!/usr/bin/env ruby
require_relative 'hexadoku'
require_relative 'solver'
require_relative 'puzzles/elektor/2011-10'

puts $puzzle.solve.to_grid_string
