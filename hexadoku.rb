require_relative 'puzzle'
require_relative 'grid'

class Hexadoku < Puzzle
  include PuzzleOnGrid

  has_glyphs (0..15).to_a
  has_glyph_chars glyphs.collect { |s| "%X"%[s] }

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

  def self.define_groups
    define_groups_for_hexadoku 0, 0
  end

  def self.define_groups_for_hexadoku(start_x, start_y)
    # Define row and column groups.
    0.upto(15).each do |n|
      define_group x:(start_x+n), y:(start_y...(start_y+16))
      define_group x:(start_x...(start_x+16)), y:(start_y+n)
    end

    # Define the 4x4 groups.
    start_x.step(start_x+15,4).each do |x|
      start_y.step(start_y+15,4).each do |y|
        define_group x:x...(x+4), y:y...(y+4)
      end
    end
  end
end

class Hexamurai < Hexadoku
  has_glyphs Hexadoku.glyphs
  has_glyph_chars Hexadoku.glyph_chars

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

  def self.define_groups
    define_groups_for_hexadoku 8, 8

    define_groups_for_hexadoku 8, 0
    define_groups_for_hexadoku 0, 8
    define_groups_for_hexadoku 16, 8
    define_groups_for_hexadoku 8, 16

    # Avoid double-counting the column and row groups
    # in the center hexadoku and avoid triple-counting the
    # box groups.
    @groups.uniq!
  end
end

