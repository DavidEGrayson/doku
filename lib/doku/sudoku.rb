require 'backports' unless defined?(require_relative)
require_relative 'puzzle'
require_relative 'grid'

module Doku
  # See my [About](/about/) page for details.  
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
      define_group row(n)
      define_group column(n)
    end
    
    0.step(6,3).each do |x|
      0.step(6,3).each do |y|
        define_group square_group(x, y)
      end
    end
  end
end

