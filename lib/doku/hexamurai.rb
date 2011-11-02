require_relative 'puzzle'
require_relative 'grid'

module Doku
  class Hexamurai < Puzzle
    include PuzzleOnGrid

    has_glyphs (0..15).to_a
    has_glyph_chars glyphs.collect { |s| "%X"%[s] }
    
    has_template <<END
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
--------+--------+--------+--------
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
--------+--------+--------+--------
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
........|........|........|........
--------+--------+--------+--------
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
        |........|........|
END

    # A track of 32 rows that runs down the center, and
    # a track of 32 columns that runs through the center.
    0.upto(31) do |n|
      define_group row(n, 8)
      define_group column(n, 8)
    end

    # The columns and rows that weren't included in the
    # defintitions above.
    0.upto(15) do |n|
      define_group row(n+8, 0)     # for the left Hexadoku
      define_group row(n+8, 16)    # for the right Hexadoku
      define_group column(n+8, 0)  # for the top Hexadoku
      define_group column(n+8, 16) # for the bottom Hexadoku
    end

    # A track of 32 4x4 groups that runs from top-to-bottom
    # and a track of 32 4x4 groups that runs from left-to-right.
    # These two tracks intersect, but that's ok because
    # define_group checks for uniqueness of groups.
    0.step(28, 4) do |n|
      8.step(20, 4) do |m|
        define_group square_group(n, m)
        define_group square_group(m, n)
      end
    end

    # Deduced groups!
    # These groups are not explicitly stated in the puzzle, but
    # we can use logic to deduce that they are groups (no
    # glyph can appear twice in them).
    # TODO: see if these deduced groups actually speed up algorithm!
    8.upto(23) do |n|
      define_group row(n, 0, 8) + row(n, 24, 8)
      define_group column(n, 0, 8) + column(n, 24, 8)
    end

  end
end

