require_relative 'dancing_links'

module Doku
  module SolvableWithDancingLinks
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

    def each_solution
      to_sparse_matrix.each_exact_cover do |exact_cover|
        yield exact_cover_to_solution exact_cover
      end
    end

    def to_sparse_matrix
      # Compute the sets (every possible glyph/square combo).
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
      
      # Create the sparse matrix.  This is a generic matrix
      # that doesn not take in to account square.given_glyph.
      sm = DancingLinks::SparseMatrix.from_sets sets
      
      # Take into account square.given_glyph by covering certain
      # rows (removing the row and all columns it touches).
      each do |square, glyph|
        sm.remove_row SquareAndGlyph.new(square,glyph)
      end

      sm
    end
    
    # Convert the exact cover to a new instance of the puzzle.
    def exact_cover_to_solution(exact_cover)
      solution = dup
      exact_cover.each do |sg|
        solution[sg.square] = sg.glyph
      end

      solution
    end
    
    class SquareAndGlyph < Struct.new(:square, :glyph)
    end
    
    class GroupAndGlyph < Struct.new(:group, :glyph)
    end
  end
end
