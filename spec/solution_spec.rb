require_relative 'spec_helper'

describe "Puzzle#solve" do
  context 'given the sudoku puzzle' do
    before do
      @puzzle = Sudoku.new <<END
...|..8|...
..7|.35|..9
5..|4.6|8..
---+---+---
...|..4|2..
4..|...|.37
8..|...|5..
---+---+---
.9.|.67|...
..3|...|1.5
...|...|..3
END

      @solution = @puzzle.solve
    end

    it 'solves the puzzle' do
      @solution.solution_for?(@puzzle).should == true
    end

    it 'is the correct solution' do
      @solution.to_grid_string.strip.should == <<END.strip
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

    it "can also find the solution using Donald Knuth's recursive DLX" do
      sm = @puzzle.to_sparse_matrix
      exact_cover = sm.find_exact_cover_recursive
      solution = @puzzle.exact_cover_to_solution exact_cover
      solution.should == @solution
    end
  end

  context 'given a sudoku puzzle with two solutions' do
    before do
      @puzzle = Sudoku.new <<END
...|..8|...
..7|.3.|..9
5..|4.6|8..
---+---+---
...|..4|2..
4..|...|.37
8..|...|5..
---+---+---
.9.|.67|...
..3|...|1.5
...|...|..3
END
    end

    it 'finds two solutions' do
      solutions = @puzzle.solutions.to_a
      solutions.size.should == 2

      solutions.should include Sudoku.new <<END
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

      solutions.should include Sudoku.new <<END
964|278|351
287|531|649
531|496|872
---+---+---
359|714|286
412|685|937
876|923|514
---+---+---
195|367|428
723|849|165
648|152|793
END

      solutions[0].should be_a_solution_for @puzzle
      solutions[1].should be_a_solution_for @puzzle
    end

  end

  context 'given a sudoku puzzle with NO solutions' do
    before do
      @puzzle = Sudoku.new <<END
123|...|...
456|...|...
78.|...|...
---+---+---
..1|...|...
...|9..|...
..2|...|...
---+---+---
..4|...|...
...|9..|...
..5|...|...
END
    end

    it 'finds no solutions' do
      @puzzle.solve.should == nil
    end

    it 'can not tell instantly there is no solution, in this case' do
      sm = @puzzle.to_sparse_matrix
      sc = sm.columns.min_by(&:size)
      sc.size.should > 0
    end

    it 'finds no solutions using the recursive algorithm' do
      sm = @puzzle.to_sparse_matrix
      sm.find_exact_cover_recursive.should == nil
    end
  end

  context 'given a hexadoku puzzle' do
    before do
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

      @solution = @puzzle.solve
    end

    it 'finds the correct solution' do
      @solution.to_grid_string.should == <<END.strip
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

  context "given a Hexamurai puzzle" do
    before do
      # From Elektor 2011-07 (with extra hints so it can be solved quickly).
      @puzzle = Doku::Hexamurai.new <<END
        |39DEA62B|80C1745F|
        |..213...|5.B4....|
        |..0.....|......2.|
        |.....4.5|..9A1.E.|
        |..3C....|.1654.0.|
        |.1..2...|3......6|
        |...90...|BD4.25..|
        |2.57....|ACE03.D1|
--------+--------+--------+--------
52.0..3.|A.....B.|0.....3.|78A....6
4.8.1...|..9.....|...E..4.|2.063...
.7......|.4F.50.9|.7.2..8E|.1..4...
..6...0.|.....C3.|...6.7.0|5..3..21
A1D24E6B|9083C.5F|E62BAD14|.....8..
E0347.28|CFA5BD96|14830E72|.9....5A
8B96FC50|ED.2134A|950CB6F8|.2.1.4.3
7.FC3A9D|1B64E2.0|FA7..9C3|0..E.2..
--------+--------+--------+--------
.3.1..7.|B.5F2.E4|31......|B.6....4
C.......|4..7..0D|..6...B.|9.40.178
..28....|.C.A..73|...49..1|..3.5.0.
047.5...|.6.1....|...045..|1....3..
..036.4.|.1.C.EA.|60473..9|........
1......2|8.4D.96.|A3EF..2.|4.5.0...
..4..51.|.7.E3...|B291..5.|....C637
6.5...8.|...9...1|8DC5..0.|........
--------+--------+--------+--------
        |...B..39|..0..2..|
        |5.804..2|.6.3.E7.|
        |...6....|....5.3.|
        |...2.7..|C4.....0|
        |..685340|.729A1..|
        |7..51...|.....6.3|
        |...4....|.B..0...|
        |...3....|0......2|
END
    end

    it "can be solved correctly" do
      solution = @puzzle.solve
      solution.should be_solution_for @puzzle
      solution.to_s.should == <<END.chomp
        |39DEA62B|80C1745F|
        |87213FDC|5EB4906A|
        |450A79E1|63DF8B2C|
        |6CBF8405|729A13ED|
        |BA3CFE7D|21654809|
        |014D25A8|39F7ECB6|
        |F6E901C3|BD4825A7|
        |28579B64|ACE03FD1|
--------+--------+--------+--------
52109D3F|AEC648B7|0F19D235|78A4BEC6
4E8D1BC5|73906AF2|D85EC14B|2F0637A9
37CA82E6|D4FB5019|C7326A8E|D19B40F5
B96FA704|5218DC3E|4BA6F790|5CE38D21
A1D24E6B|9083C75F|E62BAD14|C3F57890
E0347128|CFA5BD96|14830E72|69BDFC5A
8B96FC50|ED72134A|950CB6F8|A271E4D3
75FC3A9D|1B64E280|FA7D59C3|048E126B
--------+--------+--------+--------
D3A1087C|B95F26E4|31D870AC|B5629FE4
CFB526A3|48E7910D|5C6A23BF|9E40D178
9628E4B1|0CDAF573|2EB49861|FD375A0C
047E5FD9|3621ABC8|79F045ED|1AC863B2
FD036947|21BC8EA5|60473FD9|8B2CA51E
1AE7C3F2|854D096B|A3EF1C27|46590B8D
2849B51A|670E3FDC|B291845A|E0DFC637
6C5BD08E|FA397421|8DC5EB06|371A294F
--------+--------+--------+--------
        |AF7BC839|E50D6214|
        |5D804AF2|9613CE7B|
        |94C6B01E|FA725D38|
        |E312D756|C48BFA90|
        |CB685340|D729A1FE|
        |709512BF|48AED6C3|
        |D2F4EC9A|1B360785|
        |1EA36D87|0F5CB942|
END
    end
  end
end

