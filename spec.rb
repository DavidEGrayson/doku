require_relative 'hexadoku'
require_relative 'solver'

describe $puzzle do
  it 'has 768 squares' do
    $puzzle.squares.size.should == 768
  end
end

