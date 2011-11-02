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

  context 'given a sudoku puzzle with multiple solutions' do
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

    it 'finds multiple solutions' do
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
end

