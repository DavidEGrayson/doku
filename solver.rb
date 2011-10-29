require_relative 'puzzle'
require_relative 'dancing_links/dancing_links'

# Re-open the puzzle class and add some methods to it.
class Puzzle
  def each_solution(&block)
    Solver.each_solution self, &block
  end

  def solve
    each_solution { |s| return s }
    return nil
  end

  def solutions
    Enumerator.new do |y|
      each_solution do |solution|
        y << solution
      end
    end
  end
end

module Solver
  def self.each_solution(puzzle)
    sm = puzzle_to_sparse_matrix puzzle
    sm.each_exact_cover do |exact_cover|
      yield exact_cover_to_solution(puzzle, exact_cover)
    end
  end

  def self.puzzle_to_sparse_matrix(puzzle)
    # Compute the sets (every possible glyph/square combo).
    sets = {}
    puzzle.squares.each do |square|
      groups_with_square = puzzle.groups.select { |g| g.include? square }

      puzzle.glyphs.each do |glyph|
        sets[SquareAndGlyph.new(square, glyph)] = [square] +
          groups_with_square.collect do |group|
            GroupAndGlyph.new group, glyph
          end
      end
    end

    # Create the sparse matrix.  This is a generic matrix
    # that doesn not take in to account square.given_glyph.
    sm = DancingLinks::SparseMatrix.from_sets sets

    # Take into account square.given_glyph by covering certain
    # rows (removing the row and all columns it touches).
    puzzle.each do |square, glyph|
      sm.remove_row SquareAndGlyph.new(square,glyph)
    end

    return sm
  end

  # Convert the exact cover to a new instance of the puzzle.
  def self.exact_cover_to_solution(puzzle, exact_cover)
    solution = puzzle.dup
    exact_cover.each do |sg|
      solution[sg.square] = sg.glyph
    end
    return solution
  end

  class SquareAndGlyph < Struct.new(:square, :glyph)
  end

  class GroupAndGlyph < Struct.new(:group, :glyph)
  end

end
