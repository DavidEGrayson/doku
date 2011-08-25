require_relative 'puzzle'
require_relative 'dancing_links/dancing_links'

module Solver
  def self.solve(puzzle)
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
      if square.given_glyph
        sm.cover_row sgs[square][square.given_glyph]
      end
    end

    # Do the real work.
    exact_cover = sm.find_exact_cover
    
    # Convert the exact cover to a glyph_state hash.
    glyph_state = {}
    puzzle.squares.each do |square|
      glyph_state[square] = square.given_glyph
    end
    exact_cover.each do |sg|
      glyph_state[sg.square] = sg.glyph
    end
    return glyph_state
  end

  class SquareAndGlyph < Struct.new(:square, :glyph)
  end

  class GroupAndGlyph < Struct.new(:group, :glyph)
  end

end
