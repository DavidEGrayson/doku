require_relative 'hexadoku'
require_relative 'solver'

describe $puzzle do
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
end

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
  end
end

