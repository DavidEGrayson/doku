require_relative 'puzzle'
require_relative 'grid'

class Hexadoku < Puzzle
  include PuzzleOnGrid

  def initialize(initial_view)
    @initial_view = initial_view
    @glyphs = (0..15).to_a
    @glyph_strings = @glyphs.collect { |s| "%X"%[s] }
    parse_initial_view
    define_groups
    infer_groups
  end

  def define_groups
    define_groups_for_hexadoku 0, 0
  end

  def define_groups_for_hexadoku(start_x, start_y)
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

class Hexadoku5 < Hexadoku
  def define_groups
    define_groups_for_hexadoku 8, 8

    define_groups_for_hexadoku 8, 0
    define_groups_for_hexadoku 0, 8
    define_groups_for_hexadoku 16, 8
    define_groups_for_hexadoku 8, 16
  end
end

# From Elektor 7/8-2011
$puzzle = Hexadoku5.new <<END
        |........|.0.17...|
        |..213...|5.B4....|
        |..0.....|......2.|
        |.....4.5|..9A1.E.|
        |..3C....|.1654.0.|
        |.1..2...|3......6|
        |...90...|..4.25..|
        |2.57....|...03.D1|
--------+--------+--------+--------
52.0..3.|A.....B.|0.....3.|7......6
4.8.1...|..9.....|...E..4.|2.063...
.7......|.4F.50.9|.7.2..8E|.1..4...
..6...0.|.....C3.|...6.7.0|5..3..21
A1..4.6.|...3.7..|....AD.4|.....8..
E.......|...5B...|........|.9....5A
8.....5.|...2....|.....6F8|.2.1.4.3
.5F.3.9.|1B..E...|...D...3|0..E.2..
--------+--------+--------+--------
.3.1..7.|B.5.2...|........|B.6....4
C.......|4.......|......B.|9.40.178
..28....|.C......|.......1|..3.5.0.
047.5...|.6......|.....5..|1....3..
..036.4.|.1...EA.|6..73..9|........
1......2|8.4..96.|A3....2.|4.5.0...
..4..51.|.7..3...|...1..5.|........
6.5...8.|...9...1|8..5..0.|........
--------+--------+--------+--------
        |......39|..0..2..|
        |5.804..2|.6.3.E7.|
        |........|....5.3.|
        |...2.7..|C4.....0|
        |..6.5340|.729A1..|
        |7...1...|.....6.3|
        |...4....|.B..0...|
        |........|0......2|
END

