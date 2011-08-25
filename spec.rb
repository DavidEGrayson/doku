require_relative 'hexadoku'
require_relative 'sudoku'
require_relative 'solver'

$puzzle = $sudoku

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
  context 'given the puzzle' do
    before(:all) do
      @solution = Solver.solve $puzzle
    end

    it 'solution is consistent with given glyphs' do
      $puzzle.squares.each do |square|
        if square.given_glyph
          @solution[square].should == square.given_glyph
        end
      end
    end

    it 'contains squares glyphs' do
      @solution.each do |square, glyph|
        $puzzle.squares.should include square
        $puzzle.glyphs.should include glyph
      end
    end

    it 'is the correct solution' do
      $puzzle.glyph_state_to_string(@solution).strip.should == <<END.strip
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
end

