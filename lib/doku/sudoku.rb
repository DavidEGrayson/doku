require_relative 'puzzle'
require_relative 'grid'

module Doku
  class Sudoku < Puzzle
    include PuzzleOnGrid

    has_glyphs (1..9).to_a
    has_glyph_chars glyphs.collect &:to_s
    
    has_template <<END
...|...|...
...|...|...
...|...|...
---+---+---
...|...|...
...|...|...
...|...|...
---+---+---
...|...|...
...|...|...
...|...|...
END
    
    0.upto(8) do |n|
      define_row_group 0, n
      define_column_group n, 0
    end
    
    0.step(6,3).each do |x|
      0.step(6,3).each do |y|
        define_square_group x, y
      end
    end
  end
end

