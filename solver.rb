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

    @debug = false
  end

  def solve
    c = 0
    while not solved?
      return nil if !make_next_guess

      # tmphax status reports
      if ((c+=1) % 1000) == 0
        #puts puzzle.glyph_state_to_string(glyph_state)
      end
    end
    glyph_state
  end

  def solved?
    !glyph_state.values.include? nil
  end

  def next_square_to_guess
    unguessed_squares = puzzle.squares.select { |sq| glyph_state[sq] == nil }
    unguessed_squares.first
  end

  # Returns a new guess or nil if the puzzle is unsolvable.
  def make_next_guess
    square = next_square_to_guess
    possible_glyphs = possible_glyph_guesses(square)

    if possible_glyphs.size > 0
      push_guess Guess.new(square, possible_glyphs)
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
        print "Backtrack "        
        return push_guess guess
      end
    end
  end

  def possible_glyph_guesses(square)
    possible_glyphs = puzzle.glyphs.dup
    
    groups_that_include(square).each do |group|
      possible_glyphs -= glyphs_present_in group
    end

    return possible_glyphs
  end

  def groups_that_include square
    # TODO: try caching the result
    puzzle.groups.select { |g| g.include? square }
  end

  def glyphs_present_in(group)
    group.collect { |square| glyph_state[square] }.uniq - [nil]
  end

  def push_guess(guess)
    if @debug
      puts "Guess #{guess.square} = #{guess.glyph} (#{guess.other_possible_glyphs})"
    end

    glyph_state[guess.square] = guess.glyph
    guesses.push guess
  end

  def pop_guess
    guess = guesses.pop
    glyph_state[guess.square] = nil
    return guess
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

  def other_possible_glyphs
    g = @glyphs.dup
    g.shift
    g
  end

  def next
    if other_possible_glyphs?
      self.class.new square, other_possible_glyphs
    else
      nil
    end
  end
end
