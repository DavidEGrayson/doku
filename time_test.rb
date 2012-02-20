#!/usr/bin/env ruby
# Runs a time trial.
# The default puzzle is from the July 2011 Elektor magazine.
# Another puzzle can be specified by supplying the file name.
# You can use the recursive (Knuth style) method
$LOAD_PATH.unshift File.join File.dirname(__FILE__), 'lib'
require 'doku'

require 'rubygems'
require 'rspec'

class Doku::Puzzle
  def solve_recursive
    cover = to_link_matrix.find_exact_cover_recursive
    exact_cover_to_solution(cover) if cover
  end
end

method = :solve

if ARGV.first == '-r'
  ARGV.shift
  method = :solve_recursive
end

puzzle_file = File.join 'puzzles', 'elektor', '2011-07.rb'
if ARGV.size > 0
  puzzle_file = ARGV.shift
end
require_relative puzzle_file

puts "Solving #{puzzle_file} with #{method.inspect}..."

start_times = Process.times
solution = $puzzle.send(method)
end_times = Process.times

puts solution || "NO SOLUTION FOUND"
puts "WRONG SOLUTION FOUND" if $solution && solution != $solution
p start_times
p end_times
puts "TOTAL: %.2f" % [end_times.utime - start_times.utime]
