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

  def squares
    puzzle.squares
  end

  def glyphs
    puzzle.glyphs
  end
  
  def solve
    while not solved?
      return nil if !make_next_guess
    end
    glyph_state
  end

  def solved?
    !glyph_state.values.include? nil
  end

  def next_square_to_guess
    unguessed_squares = squares.select { |sq| glyph_state[sq] == nil }
    unguessed_squares.first
  end

  # Returns a new guess or nil if the puzzle is unsolvable.
  def make_next_guess
    square = next_square_to_guess
    possible_glyphs = possible_glyph_guesses(square)

    if possible_glyphs.size > 0
      g = Guess.new(square, possible_glyphs)
      #puts "Created guess #{g.inspect}"
      push_guess g
    else
      backtrack_and_guess
    end
  end

  # Returns the new guess or nil if the puzzle is unsolvable.
  def backtrack_and_guess
    while true
      if guesses.empty?
        # Unsolvable puzzle.
        return false
      elsif guess = pop_guess.next
        return push_guess guess
      end
    end
  end

  def possible_glyph_guesses(square)
    possible_glyphs = glyphs.dup
    
    # TODO: finish this
  end

  def push_guess(guess)
    puts "Guess #{guess.square.inspect} = #{guess.glyph}"
    glyph_state[guess.square] = guess.glyph
    guesses.push guess
  end

end

class Solver::Guess
  attr_accessor :square
  attr_accessor :glyphs   # first in Array is the current guess; others are the other possible guesses

  def initialize(square, glyphs)
    @square = square
    @glyphs = glyphs.dup  # TODO: remove duping here if you can
  end

  def glyph
    @glyphs.first
  end

  def other_possible_glyphs?
    @glyphs.size > 1
  end

  def next
    if other_possible_glyphs?
      g = glyphs.dup
      g.pop
      self.class.new square, g
    else
      nil
    end
  end
end
