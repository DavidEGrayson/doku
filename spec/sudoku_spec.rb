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
end

