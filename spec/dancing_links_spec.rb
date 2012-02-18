require 'backports' unless defined? require_relative
require_relative 'spec_helper'

describe Doku::DancingLinks::LinkMatrix do
  context "when created from scratch" do
    before do
      @sm = Doku::DancingLinks::LinkMatrix.new
    end

    it "has no columns (i.e. it is empty)" do
      @sm.columns.to_a.size.should == 0
      @sm.should be_empty
    end
  end

  shared_examples_for "figure 3 from Knuth" do
    it "has 7 columns" do
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
      @universe = [1,2,3,4,5,6,7]
      @subsets = [[    3,  5,6  ],
                  [1,    4,    7],
                  [  2,3,    6  ],
                  [1,    4      ],
                  [  2,        7],
                  [      4,5,  7],
                 ]
      @sm = Doku::DancingLinks::LinkMatrix.from_sets @subsets, @universe
    end

    it_should_behave_like "figure 3 from Knuth"

    it "can find an exact cover" do
      result = @sm.find_exact_cover
      result.collect(&:sort).sort.should == [[1, 4], [2, 7], [3, 5, 6]]
    end

    # TODO: test this using a matrix that has multiple exact covers
    it "can find all exact covers" do
      @sm.exact_covers.to_a.sort.should == [[[1, 4], [3, 5, 6], [2,7]]]
    end

    context "with one row covered" do
      before do
        @sm.column(@universe[3]).cover
      end

      it "has only 6 columns" do
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
          @sm.column(@universe[3]).uncover          
        end

        it_should_behave_like "figure 3 from Knuth"
      end
    end
  end
end
