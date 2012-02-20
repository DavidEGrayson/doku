require 'backports' unless defined?(require_relative) and defined?(Enumerator)
require_relative 'dancing_links'

module Doku
  # This module is included into the {Puzzle} class to provide methods
  # for solving the puzzles using the {DancingLinks} algorithm.
  module SolvableWithDancingLinks
    # @return (Puzzle)
    # Returns the first solution found by the Dancing Links algorithm,
    # or nil if there is no solution.
    def solve
      each_solution { |s| return s }
      return nil
    end

    # An enumerator for all the solutions to the puzzle.
    # @return (Enumerable)
    def solutions
      Enumerator.new do |y|
        each_solution do |solution|
          y << solution
        end
      end
    end

    # This method lets you iterate over each solution.
    # Each solution is a puzzle object of the same class
    # such that solution.solution_for?(puzzle) is true.
    #
    # @yield [solution]
    def each_solution
      to_link_matrix.each_exact_cover do |exact_cover|
        yield exact_cover_to_solution exact_cover
      end
    end

    # Returns a {DancingLinks::LinkMatrix} that represents this puzzle.
    # Every row is a {SquareAndGlyph} object representing a choice to
    # assign a certain glyph to a certain square.
    # Every column is a {GroupAndGlyph} object representing the
    # requirements that needs to be satisfied (every group must have
    # exactly one of each glyph assigned to a square in the group).
    # @return (DancingLinks::LinkMatrix)
    def to_link_matrix
      # Create the link matrix.  This is a generic matrix
      # that does not take in to account square.given_glyph.
      sm = DancingLinks::LinkMatrix.from_sets sets_for_exact_cover_problem
      
      # Take into account square.given_glyph by covering certain
      # rows (removing the row and all columns it touches).
      each do |square, glyph|
        sm.remove_row SquareAndGlyph.new(square,glyph)
      end

      sm
    end

    # Converts an exact cover (an array of {SquareAndGlyph} objects) to a
    # solution of the puzzle.
    # @return (Puzzle)
    def exact_cover_to_solution(exact_cover)
      solution = dup
      exact_cover.each do |sg|
        solution[sg.square] = sg.glyph
      end

      solution
    end

    private

    def sets_for_exact_cover_problem
      sets = {}
      squares.each do |square|
        groups_with_square = groups.select { |g| g.include? square }
        
        glyphs.each do |glyph|
          sets[SquareAndGlyph.new(square, glyph)] = [square] +
            groups_with_square.collect do |group|
              GroupAndGlyph.new group, glyph
            end
        end
      end

      sets
    end
    
    # This is a simple class that just represents the choice of a puzzle's
    # square and a puzzle's glyph.  These are identified with rows in
    # the {DancingLinks::LinkMatrix} when solving puzzles, and there they
    # represent the choice to assign a particula glyph to a particular square.
    class SquareAndGlyph < Struct.new(:square, :glyph)
    end
    
    # This is a simple class that just represents the choice of a puzzle's
    # group of squares and a glyph.  These are identifies with columns in
    # the {DancingLinks::LinkMatrix} when solving puzzles, and they
    # represent a requirement that must be satisfied; every group must
    # has one of every glyph assigned to a square in it.
    class GroupAndGlyph < Struct.new(:group, :glyph)
    end
  end
end
