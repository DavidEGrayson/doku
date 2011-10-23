require_relative 'spec_helper'

class TestPuzzle < Puzzle
  has_squares [1,2,3,4]
  has_glyphs  [true,false]
  
  define_group [1,2]
  define_group [2,3]
  define_group [3,4]
  define_group [4,1]
end

describe "Puzzle instance" do
  before do
    @puzzle = TestPuzzle.new(1 => true)
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

  it "can not be initialized with bad data" do
    lambda { TestPuzzle.new(:foo => true) }.should raise_error IndexError
    lambda { TestPuzzle.new(1 => :foo) }.should raise_error ArgumentError
  end

  describe "comparison operators say" do
    it "A <= B iff square=>glyph pairs in A are a subset of those in B" do
      @puzzle.should_not <= TestPuzzle.new
      TestPuzzle.new.should <= @puzzle

      @puzzle.should <= @puzzle

      @puzzle.should <= TestPuzzle.new(1 => true, 3 => false)
    end

    it "A == B iff the square=>glyph pairs in A and B are the same" do
      @puzzle.should_not == TestPuzzle.new
      TestPuzzle.new.should_not == @puzzle.should

      puzzle2 = TestPuzzle.new(1 => true)
      @puzzle.should == puzzle2
      puzzle2.should == @puzzle

      (TestPuzzle.new(1 => true) != @puzzle).should == false
    end

    it "A < B if and only if A != B and A <= B" do
      TestPuzzle.new.should < @puzzle
      @puzzle.should_not < TestPuzzle.new
    end

    it "A >= B if and only if B <= A" do
      TestPuzzle.new.should_not >= @puzzle
      @puzzle.should >= TestPuzzle.new

      @puzzle.should >= @puzzle

      TestPuzzle.new(1 => true, 3 => false).should >= @puzzle
    end

    it "A > B if and only if B < A" do
      @puzzle.should > TestPuzzle.new
      TestPuzzle.new.should_not > @puzzle
    end
  end

  describe "#filled?" do
    it "returns true iff all squares have been assigned a glyph" do
      TestPuzzle.new(1 => true, 2=> true, 3 => false, 4 => false).should be_filled
      @puzzle.should_not be_filled
    end
  end

  describe "#valid?" do
    it "returns false iff a group has the same glyph in it twice" do
      @puzzle.should be_valid
      TestPuzzle.new(1 => true, 2=> true).should_not be_valid      
    end
  end

  describe "#solution?" do
    it "returns true iff it is filled and valid" do
      puzzle2 = TestPuzzle.new(1 => false, 2 => true, 3 => false, 4 => true)
      puzzle2.should be_a_solution

      puzzle3 = TestPuzzle.new(1 => true, 2=> true, 3 => false, 4 => false)
      puzzle3.should_not be_a_solution
    end
  end

  describe "#solution_for?(puzzle)" do
    it "returns true if this puzzle is a solution and a super set of the other puzzle" do
      puzzle4 = TestPuzzle.new(1 => false, 2 => true, 3 => false, 4 => true)
      puzzle4.should_not be_a_solution_for @puzzle

      puzzle5 = TestPuzzle.new(1 => true, 2 => false, 3 => true, 4 => false)
      puzzle5.should be_a_solution_for @puzzle
    end
  end

end
