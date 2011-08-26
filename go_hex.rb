#!/usr/bin/env ruby
require_relative 'hexadoku'
require_relative 'solver'

solution = Solver.solve $hexadoku

expected = <<END
unknown
END

solution_string = $sudoku.glyph_state_to_string(solution)

if solution_string.strip != expected.strip
  puts "FAILED"
  puts solution_string
  exit 1 
end

puts "Success".
puts exit 0
