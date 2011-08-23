require_relative 'hexadoku'
require_relative 'sudoku'
require_relative 'solver'

$puzzle = $sudoku

describe 'Hexadoku5 $puzzle' do
  it 'has 768 squares' do
    $puzzle.squares.size.should == 768
  end

  it 'has 16 squares in the first row' do
    first_row = $puzzle.squares.select { |s| s.matches?(y:0) }
    first_row.size.should == 16
  end

  it 'has 16 squares in the first column of the top puzzle' do
    first_row = $puzzle.squares.select { |s| s.matches? x:8, y:(0..15) }
  end

  it 'has the right number of groups' do
    # A hexadoku has 3*16 groups (16 columns, 16 rows, 16 boxes)
    # There are 5 hexadokus.
    # The reckoning above counted the 32 rows and columns of the 
    # center hexadoku twice, and counted the 16 boxes of the
    # center hexaodoku thrice, so subtract 64.
    # There are 2*16 inferred groups (16 columns, 16 rows).
    $puzzle.groups.size.should == 5*3*16 - 64 + 2*16
  end

  it 'has valid line and char numbers' do
    lines = $puzzle.initial_view.split("\n")
    $puzzle.squares.each do |square|
      line = lines[square.line_number]
      line.should_not be_nil
      line.size.should > square.char_number
    end
  end
end if $puzzle.is_a? Hexadoku5

describe "Sudoku $puzzle" do
  it 'has 81 squares' do
    $puzzle.squares.size.should == 81
  end

  it 'has 9 squares in the first row' do
    first_row = $puzzle.squares.select { |s| s.matches?(y:0) }
  end

  it 'has the right number of groups' do
    $puzzle.groups.size.should == 3*9
  end
end if $puzzle.is_a? Sudoku

describe Solver do
  context 'given the puzzle' do
    before(:all) do
      @solution = Solver.solve $puzzle
    end

    it 'solution is consistent with given glyphs' do
      $puzzle.squares.each do |square|
        if square.given_glyph
          square.given_glyph.should == @solution[square]
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
      puts $puzzle.glyph_state_to_string @solution
    end
  end
end

