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
    end
  end

  shared_examples_for "figure 3 from Knuth" do
    it "has 7 columns" do
      @sm.column_count.should == 7
      @sm.columns.to_a.size.should == 7
    end

    it "has the expected columns" do
      @sm.columns.collect(&:id).should == @universe
    end

    it "has the expected structure" do
      # This test is not exhaustive.
      columns = @sm.columns.to_a
      columns[0].down.should_not == columns[0]
      columns[0].up.should_not == columns[0]
      columns[0].nodes.to_a.size.should == 2
      columns[0].up.up.should == columns[0].down
      columns[0].up.should == columns[0].down.down

      columns[0].down.right.up.should == columns[3]
      columns[3].down.left.up.should == columns[0]
      columns[0].down.down.right.up.up.should == columns[3]
      columns[0].down.down.right.right.right.down.down.should == columns[3]
      columns[2].up.right.down.should == columns[5]

      columns[6].down.down.down.left.up.left.down.left.down.down.should == columns[1]
    end

    it "every row has a reference to the column" do
      @sm.columns.each do |column|
        column.nodes.each do |node|
          node.column.should == column
        end
      end
    end
  end

  context "given figure 3 from Knuth" do
    before do
      @universe = u = (1..7).collect { Object.new }
      @subsets = [
                  [          u[2],     u[4],u[5]    ],
                  [u[0],          u[3],         u[6]],
                  [     u[1],u[2],          u[5]    ],
                  [u[0],          u[3]              ],
                  [     u[1],                   u[6]],
                  [               u[3],u[4],    u[6]],
                 ]
      @sm = DancingLinks::SparseMatrix.from_sets @subsets, @universe
    end

    it_should_behave_like "figure 3 from Knuth"

    context "with one row covered" do
      before do
        @sm.cover_column @sm.column(@universe[3])
      end

      it "has only 6 columns" do
        @sm.column_count.should == 6
        @sm.columns.to_a.size.should == 6
      end

      # @sm will now look like (minus means a covered element)
      # 0 0 1 - 1 1 0
      # - - - - - - -
      # 0 1 1 - 0 1 0
      # - - - - - - -
      # 0 1 0 - 0 0 1
      # - - - - - - -
      it "has the expected column sizes" do
        @universe.collect { |e| @sm.column(e).size }.should == [0, 2, 2, 3, 1, 2, 1]
        @sm.columns.collect { |c| c.size }.should == [0, 2, 2, 1, 2, 1]
      end

      it "has the expected structure" do
        columns = @sm.columns.to_a

        # Column 0 is empty.
        columns[0].down.should == columns[0]
        columns[0].up.should == columns[0]
        columns[0].nodes.to_a.should be_empty

        columns[1].down.right.up.up.should == columns[2]
        columns[2].down.right.up.should == columns[3]
        columns[3].up.right.down.down.should == columns[4]
        columns[5].down.right.down.should == columns[1]

        columns[5].up.left.up.right.up.right.right.down.down.should == columns[4]
      end

      context "and then uncovered" do
        before do
          @sm.uncover_column @sm.column(@universe[3])          
        end

        it_should_behave_like "figure 3 from Knuth"
      end
    end
  end
end
