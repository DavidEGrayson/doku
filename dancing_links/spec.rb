require_relative 'dancing_links'
require 'set'

describe DancingLinks::SparseMatrix do
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
      columns = @sm.columns.to_a
      Set.new(columns.collect &:id).should == Set.new(@universe)
    end
  end
end
