require_relative 'dancing_links'
require 'set'

describe DancingLinks::LinkEnumerator do
  it "has a nice inspect function" do
    e = DancingLinks::LinkEnumerator.new :pred, 1, -3
    e.to_a.should == [1,0,-1,-2]
  end
end

describe DancingLinks::SparseMatrix do
  context "when created from scratch" do
    before do
      @sm = DancingLinks::SparseMatrix.new
    end

    it "has no columns" do
      @sm.columns.to_a.size.should == 0
      @sm.columns.each { |c| raise }
    end
  end

  context "given figure 3 from Knuth" do
    before do
      @universe = u = (1..7).collect { |e| Object.new }
      @subsets = [
                 [u[2], u[4], u[5]],
                 Set.new([u[0], u[3], u[6]]),
                 Set.new([u[1], u[2], u[5]]),
                 Set.new([u[0], u[3]]),
                 Set.new([u[1], u[6]]),
                 Set.new([u[3], u[4], u[6]]),
                ]
      @sm = DancingLinks::SparseMatrix.from_sets @subsets
    end

    it "has 7 columns" do
      @sm.column_count.should == 7
    end

    it "has the expected columns" do
      column_ids = @sm.columns.collect &:id
      Set.new(column_ids).should == Set.new(@universe)
      columns = @universe.collect { |e| @sm.column e }
      columns[0].down.right.up.should == columns[3]
      columns[0].down.should_not == columns[0]
      columns[0].rows.to_a.size.should == 2
      columns[0].down.should == columns[0][0]
    end
  end
end
