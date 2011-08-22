require_relative 'puzzle'

class Solver
  attr_accessor :puzzle
  attr_accessor :glyph_state    # Hash of square => glyph
  attr_accessor :guesses        # Array of Guess objects, most recent first

  def self.solve(puzzle)
    new(puzzle).solve
  end

  def initialize(puzzle)
    @puzzle = puzzle
    @guesses = []
    @glyph_state = puzzle.squares.each_with_object({}) do |square, h|
      h[square] = square.given_glyph
    end
  end
  
  def solve
    #while !solved?
      
    #end
    glyph_state
  end

  def solved?
    !glyph_state.values.include? nil
  end
end

class Solver::Guess
  attr_accessor :square
  attr_accessor :glyph
end
