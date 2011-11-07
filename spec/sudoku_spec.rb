require 'backports' unless defined? require_relative
require_relative 'spec_helper'

describe Doku::Sudoku do
  before do
    @puzzle = Sudoku.new
  end

  it 'has 81 squares' do
    Sudoku.squares.size.should == 81
  end

  it 'has 9 squares in the first row' do
    first_row = Sudoku.squares.select { |s| s.matches?(:y => 0) }
    first_row.size.should == 9
  end

  it 'has the right number of groups' do
    Sudoku.groups.size.should == 3*9
  end

  it 'has methods for getting and setting glyphs by coordinates' do
    # (just like any puzzle class that includes the PuzzleOnGrid module)

    @puzzle.get(0, 1).should == nil
    @puzzle.set(0, 1, 4)
    @puzzle.set(5, 7, 9)
    @puzzle.set(6, 6, 1)
    @puzzle.set(6, 6, nil)
    @puzzle.get(0, 1).should == 4
    @puzzle.to_s.should == <<END.strip
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

  it "the get method has a good error message" do
    msg = "Square not found in Doku::Sudoku: Square(19, david)."
    lambda { @puzzle.get(19, 'david') }.should raise_error IndexError, msg
    lambda { @puzzle.set(19, 'david', 10) }.should raise_error IndexError, msg
  end
end

