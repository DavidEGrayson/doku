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
    # Compute the universe (square and every group/glyph combo).
    universe = puzzle.squares.dup
    ggs = {}
    puzzle.groups.each do |group|
      ggs[group] = l = {}
      puzzle.glyphs.each do |glyph|
        universe << l[glyph] = GroupAndGlyph.new(group, glyph)
      end
    end

    # Compute the sets (every possible glyph/square combo).
    sets = {}
    sgs = {}
    puzzle.squares.each do |square|
      sgs[square] = l = {}
      puzzle.glyphs.each do |glyph|
        set = [square]
        puzzle.groups.each do |group|
          if group.include? square
            set << ggs[group][glyph]
          end
        end

        sets[l[glyph] = SquareAndGlyph.new(square, glyph)] = set
      end
    end

    # Create the sparse matrix.  This is a generic matrix
    # that doesn not take in to account square.given_glyph.
    sm = DancingLinks::SparseMatrix.from_sets sets, universe

    # Take into account square.given_glyph by covering certain
    # rows (removing the row and all columns it touches).
    puzzle.squares.each do |square|
      if glyph = puzzle[square]
        sm.remove_row sgs[square][glyph]
      end
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
