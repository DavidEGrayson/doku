#!/usr/bin/env ruby
require_relative 'sudoku'
require_relative 'solver'

solution = Solver.solve $sudoku

expected = <<END
964|278|351
287|135|649
531|496|872
---+---+---
319|754|286
452|681|937
876|923|514
---+---+---
195|367|428
723|849|165
648|512|793
END

if $sudoku.glyph_state_to_string(solution).strip != expected.strip
  puts "FAILED"
  puts solution
  exit 1 
end

puts "Success".
puts exit 0
