require_relative 'puzzle'
require_relative 'dancing_links/dancing_links'

module Solver
  Profile = false

  require 'ruby-prof' if Profile

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
      if glyph = puzzle[square]
        sm.remove_row sgs[square][glyph]
      end
    end

    # Do the real work.
    RubyProf.start if Profile

    exact_cover = sm.find_exact_cover
    
    if Profile
      result = RubyProf.stop
      printer = RubyProf::GraphHtmlPrinter.new(result)
      File.open("profile.html", 'w') do |file|
        printer.print file, :min_percent=>2.0
      end
    end

    # Convert the exact cover to a new instance of the puzzle.
    solution = puzzle.dup
    exact_cover.each do |sg|
      solution[sg.square] = sg.glyph
    end

    # TODO: if !(puzzle <= solution && solution.complete?)
    #   raise "There was a bug in the solving algorithm."
    # end
    
    return solution
  end

  class SquareAndGlyph < Struct.new(:square, :glyph)
  end

  class GroupAndGlyph < Struct.new(:group, :glyph)
  end

end
