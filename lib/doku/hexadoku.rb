require 'backports' unless defined?(require_relative)
require_relative 'puzzle'
require_relative 'grid'

module Doku
  # This class represents Hexadoku, otherwise known as 16x16 {Sudoku}.
  # This is a more complex version of Sudoku with a 16x16 grid, using
  # hex digits 0 through F.
  # Each instance of this class represents a particular arrangement of
  # numbers written in the boxes.
  class Hexadoku < Puzzle
    include PuzzleOnGrid

    has_glyphs (0..15).to_a
    has_glyph_chars glyphs.collect { |s| '%x'%[s] }

    has_template <<END
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
END

    # Define row and column groups.
    0.upto(15).each do |n|
      define_group row(n)
      define_group column(n)
    end
    
    # Define the 4x4 groups.
    0.step(12,4).each do |x|
      0.step(12,4).each do |y|
        define_group square_group(x, y)
      end
    end
    
  end

end

