require_relative 'hexadoku'
require_relative 'sudoku'
require_relative 'solver'

describe 'Hexadoku5 puzzle' do
  it 'has 768 squares' do
    $hexadoku.squares.size.should == 768
  end

  it 'has 16 squares in the first row' do
    first_row = $hexadoku.squares.select { |s| s.matches?(y:0) }
    first_row.size.should == 16
  end

  it 'has 16 squares in the first column of the top hexadoku' do
    first_row = $hexadoku.squares.select { |s| s.matches? x:8, y:(0..15) }
  end

  it 'has the right number of groups' do
    # A hexadoku has 3*16 groups (16 columns, 16 rows, 16 boxes)
    # There are 5 hexadokus.
    # The reckoning above counted the 32 rows and columns of the 
    # center hexadoku twice, and counted the 16 boxes of the
    # center hexaodoku thrice, so subtract 64.
    # There are 2*16 inferred groups (16 columns, 16 rows).
    $hexadoku.groups.size.should == 5*3*16 - 64 + 2*16
  end

  it 'has valid line and char numbers' do
    lines = $hexadoku.initial_view.split("\n")
    $hexadoku.squares.each do |square|
      line = lines[square.line_number]
      line.should_not be_nil
      line.size.should > square.char_number
    end
  end
end

describe "Sudoku puzzle" do
  it 'has 81 squares' do
    $sudoku.squares.size.should == 81
  end

  it 'has 9 squares in the first row' do
    first_row = $sudoku.squares.select { |s| s.matches?(y:0) }
  end

  it 'has the right number of groups' do
    $sudoku.groups.size.should == 3*9
  end
end

describe Solver do
  context 'given the sudoku puzzle' do
    before(:all) do
      @solution = Solver.solve $sudoku
    end

    it 'solution is consistent with given glyphs' do
      $sudoku.squares.each do |square|
        if square.given_glyph
          @solution[square].should == square.given_glyph
        end
      end
    end

    it 'contains squares glyphs' do
      @solution.each do |square, glyph|
        $sudoku.squares.should include square
        $sudoku.glyphs.should include glyph
      end
    end

    it 'is the correct solution' do
      $sudoku.glyph_state_to_string(@solution).strip.should == <<END.strip
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
    end
  end

  context 'given a hexadoku puzzle' do
    before(:all) do
      # Elektor Hexadoku 2011
      @puzzle = Hexadoku.new <<END
2A.7|.C..|9D64|8...
..3.|A..D|7...|.2F.
.1..|..0.|8...|.4AB
....|.7.2|..BC|.0.3
----+----+----+----
C2.8|.D3.|..4E|....
..FA|7.2.|B.3.|1C04
....|4..F|..1.|...E
9..B|1...|....|23..
----+----+----+----
..8C|....|...0|3..D
6...|.F..|1..A|....
D37E|.0.1|.9.8|AF..
....|3B..|.2D.|C.80
----+----+----+----
F.B.|51..|2.A.|....
3CA.|...7|.E..|..6.
.E4.|...9|3..5|.D..
...1|F3A4|..9.|5.E2
END

      @solution = Solver.solve @puzzle
    end

    it "gives the correct solution" do
      @puzzle.glyph_state_to_string(@solution).should == <<END
2A07|BCF3|9D64|8E15
B839|A54D|70E1|62FC
51CD|E906|8F23|74AB
46EF|8712|A5BC|D093
----+----+----+----
C218|6D3B|074E|9A5F
EDFA|7825|B639|1C04
0753|4A9F|C812|B6DE
946B|1EC0|DA5F|2378
----+----+----+----
158C|946A|EBF0|372D
6B20|CFD8|137A|E549
D37E|2051|49C8|AFB6
AF94|3B7E|52D6|C180
----+----+----+----
F9B6|51EC|24AD|0837
3CA5|D287|FE0B|4961
7E42|06B9|3185|FDCA
80D1|F3A4|6C97|5BE2
END
    end
  end
end

