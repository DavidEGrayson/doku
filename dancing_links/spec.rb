require_relative 'dancing_links'
require 'set'

describe DancingLinks::SparseMatrix do
  it "can be initialized from a universe and a set of sets" do
    universe = u = (1..7).collect { |e| Object.new }
    subsets = [
      [u[2], u[4], u[5]],
      Set.new([u[0], u[3], u[6]]),
      Set.new([u[1], u[2], u[5]]),
      Set.new([u[0], u[3]]),
      Set.new([u[1], u[6]]),
      Set.new([u[3], u[4], u[6]]),
    ]
    sm = DancingLinks::SparseMatrix.from_sets subsets
  end
end
