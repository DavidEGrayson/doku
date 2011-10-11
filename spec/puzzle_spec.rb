require_relative 'spec_helper'

class TestPuzzle < Puzzle
  has_squares [1,2,3,4]
  has_glyphs  [true,false]
  
  define_group [1,2]
  define_group [2,3]
  define_group [3,4]
  define_group [4,1]
end

describe Puzzle do
  it "is an abstract class" do
    Puzzle.should be_a_kind_of Class
  end
end

describe "Puzzle instance" do
  before do
    @puzzle = TestPuzzle.new
    @puzzle[1] = true
  end

  it "is basically a hash of square => glyph" do
    @puzzle[1].should == true
    @puzzle[4].should == nil

    @puzzle[1] = false
    @puzzle[1].should == false

    @puzzle[1] = nil
    @puzzle[1].should == nil
  end

  it "only allows squares as keys" do
    lambda { @puzzle[0] }.should raise_error IndexError
    lambda { @puzzle[0] = false }.should raise_error IndexError
  end

  it "only allows glyphs or nil as values" do
    lambda { @puzzle[1] = 10 }.should raise_error ArgumentError
  end


end
