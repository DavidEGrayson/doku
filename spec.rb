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
end

