require_relative 'spec_helper'

describe Doku::Sudoku do
  it 'has 81 squares' do
    Sudoku.squares.size.should == 81
  end

  it 'has 9 squares in the first row' do
    first_row = Sudoku.squares.select { |s| s.matches?(y:0) }
    first_row.size.should == 9
  end

  it 'has the right number of groups' do
    Sudoku.groups.size.should == 3*9
  end

  it 'has methods for getting and setting glyphs by coordinates' do
    p = Sudoku.new
    p.get(0, 1).should == nil
    p.set(0, 1, 4)
    p.set(5, 7, 9)
    p.set(6, 6, 1)
    p.set(6, 6, nil)
    p.get(0, 1).should == 4
    p.to_s.should == <<END.strip
...|...|...
4..|...|...
...|...|...
---+---+---
...|...|...
...|...|...
...|...|...
---+---+---
...|...|...
...|..9|...
...|...|...
END
  end
end

