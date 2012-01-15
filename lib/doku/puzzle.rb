require 'set'
require 'backports' unless defined?(require_relative)
require_relative 'solver'

module Doku

  # @abstract Use the {Sudoku}, {Hexadoku}, or {Hexamurai}
  #   subclasses or make a subclass to represent your own type
  #   of Sudoku-like puzzle.
  #
  # This in abstract class for creating classes that represent
  # Sudoku-like puzzles.
  #
  # Every subclass of {Doku::Puzzle} represents a Sudoku-like puzzle consisting
  # of a set of glyphs, a set of squares, and a set of groups of squares.
  # For example, the {Doku::Sudoku} subclass represents the famous 9x9 puzzle,
  # Sudoku.
  #
  # Every instance of a subclass of Puzzle represents a particular state
  # of that type of puzzle, i.e. a record of which glyph is assigned
  # to each square.
  class Puzzle
    include SolvableWithDancingLinks

    # A hash that associates squares to glyphs, representing
    # the arrangement of glyphs in the puzzle.
    attr_reader :glyph_state

    # Creates a new instance of the puzzle.
    #
    # @param [Hash] glyph_state The state of the puzzle, represented as a hash
    # where the keys are squares and the values are nil or glyphs in the context
    # of this puzzle class.  For example, this represents what numbers have been
    # written in the boxes of a {Sudoku} puzzle.
    def initialize(glyph_state = {})
      @glyph_state = {}
      # We initialize glyph_state this way so that the data gets validated.
      glyph_state.each { |square, glyph| self[square] = glyph }
    end

    class << self
      
      # Returns an array of all the valid glyphs for this class of puzzle.
      # A glyph can be any type of Ruby object, and it is meant to
      # represent a symbol which can be drawn inside a square in a
      # Sudoku-like puzzle.
      #
      # For example, the glyphs for {Sudoku} are the Ruby integers 1, 2, 3,
      # 4, 5, 6, 7, 8, and 9.
      #
      # The glyphs, squares, and groups, are defined at the class level, in the subclasses of Doku::Puzzle.
      # @return [Array] Array of objects representing glyphs.
      attr_reader :glyphs

      # Returns an array of all the valid squares in this class of puzzle.
      # A square can be any type of Ruby object, and it is meant to
      # represent a square in which glyphs are drawn in a Sudoku-like puzzle.
      # 
      # For example, there are 81 squares defined in the {Sudoku} class,
      # one for each square on the 9x9 Sudoku grid.
      #
      # The glyphs, squares, and groups, are defined at the class level, in the subclasses of Doku::Puzzle.
      # @return [Array] Array of objects representing squares.
      attr_reader :squares

      # Returns an array of all the groups for this class of puzzle.
      # A group should be a Set object that contains some squares.
      # A group represents a constraint on solutions to the puzzle:
      # every glyph must appear exactly once in every group.
      #
      # For example, the groups of the {Sudoku} class represent the
      # nie columns, nine rows, and nine 3x3 boxes of Sudoku.
      #
      # The glyphs, squares, and groups, are defined at the class level, in the subclasses of Doku::Puzzle.
      # @return [Array] Array of glyphs.
      attr_reader :groups
    end

    # Shortcut for calling the {Puzzle.glyphs} class method.
    # @return [Array] Array of glyphs.
    def glyphs
      self.class.glyphs
    end

    # Shortcut for calling the {Puzzle.squares} class method.
    # @return [Array] Array of squares.
    def squares
      self.class.squares
    end

    # Shortcut for calling the {Puzzle.groups} class method.
    # @return [Array] Array of groups.
    def groups
      self.class.groups
    end

    # Gets the glyph assigned to the given square.
    # @param square Must be one of the {Puzzle.squares} for this puzzle.
    # @return The glyph that is assigned to the given square
    #   (one of the {Puzzle.glyphs} defined for this puzzle),
    #   or nil if no glyph is assigned.
    def [](square)
      raise IndexError, "Square not found in #{self.class.name}: #{square}." if !squares.include?(square)
      @glyph_state[square]
    end

    # Sets the glyph assigned to the given square.
    # @param square Must be one of the {Puzzle.squares} for this puzzle.
    # @param glyph Must be one of the {Puzzle.glyphs} for this puzzle, or nil.
    def []=(square, glyph)
      raise IndexError, "Square not found in #{self.class}: #{square}." if !squares.include?(square)
      raise ArgumentError, "Value must be a glyph in this puzzle or nil." if !glyph.nil? && !glyphs.include?(glyph)

      # Do NOT store nils as values in the hash, because we
      # don't want them to affect equality comparisons.
      if glyph == nil
        @glyph_state.delete square
      else
        @glyph_state[square] = glyph
      end
    end

    # This method allows you to iterate over every square that has a
    # glyph assigned to it.
    #
    # @yield [square, glyph]
    # @yieldparam square A square that has a glyph assigned to it.
    # @yieldparam glyph The glyph that is assigned to the square.
    def each(&block)
      @glyph_state.each(&block)
    end

    # @return [Fixnum] Returns a hash code based on the glyph assignments.
    def hash
      @glyph_state.hash
    end

    # Two puzzles are equal if they have the same class and glyph assignments. 
    # @return [Boolean] True if the two puzzles are equal.
    def eql?(puzzle)
      self.class == puzzle.class and glyph_state == puzzle.glyph_state
    end

    # Same as {#eql?}.
    def == (puzzle)
      eql? puzzle
    end

    # Returns true if the puzzle's glyphs assignments are a subset
    # of the given puzzle's glyph assignments and the two puzzles are
    # the same class.
    #
    # Every puzzle is a subset of itself.
    #
    # For example, if you find a Sudoku puzzle and start working on it,
    # you have changed the original puzzle into a new puzzle.
    # The original puzzle will be a subset of the new puzzle,
    # assuming you didn't erase any numbers.
    #
    # @return [Boolean]
    def subset?(puzzle)
      self.class == puzzle.class and glyph_assignment_subset?(puzzle)
    end

    # Returns true if this puzzle is completely filled in,
    # which means every square has a glyph assigned to it.
    # For example, a Sudoku puzzle is considered to be filled after
    # you have written a number in every box, regardless of whether
    # the numbers obey the rules of Sudoku or not.
    # See also {#solution?} and {#solution_for?}.
    #
    # @return [Boolean]
    def filled?
      squares.size == glyph_state.keys.size
    end

    # Returns true if this puzzle follows the rules.
    # A puzzle is valid if no glyph appears twice in any group.
    # For example, a {Sudoku} puzzle would be invalid if you
    # wrote a "3" twice in the same column.
    #
    # @return [Boolean]
    def valid?
      groups.each do |group|
        gs = group.collect { |square| self[square] } - [nil]
        return false if gs.uniq.size != gs.size
      end
      return true
    end

    # Returns true if the puzzle is {#filled?} and {#valid?}.
    # @return [Boolean]
    def solution?
      filled? and valid?
    end

    # Returns true if the puzzle is valid solution for the given puzzle.
    #
    # @return [Boolean]
    def solution_for?(puzzle)
      solution? and puzzle.subset?(self)
    end

    private

    # This is called when the puzzle is duped or cloned.
    def initialize_copy(source)
      @glyph_state = @glyph_state.dup
    end

    # This should be called inside the definition of a Puzzle subclass
    # to define what glyphs the puzzle has.
    def self.has_glyphs(glyphs)
      @glyphs = glyphs
    end

    # This should be called inside the definition of a Puzzle subclass
    # to define what squares the puzzle has.
    # This method defines one square at a time.  See also #has_squares.
    def self.define_square(square)
      raise ArgumentError, "square should not be nil" if square.nil?
      @squares ||= []
      @squares << square
    end

    # This should be called inside the definition of a Puzzle subclass
    # to define what squares the puzzle has.
    # This method defines all the squares at once.  See also #define_square.
    def self.has_squares(squares)
      raise ArgumentError, "list of squares should not contain nil" if squares.include? nil
      @squares = squares.uniq
    end

    def glyph_assignment_subset?(puzzle)
      glyph_state.each_pair do |square, glyph|
        return false if puzzle[square] != glyph
      end
      return true
    end

    def self.define_group(squares)
      group = Set.new(squares)
      raise ArgumentError, "Expected groups to be of size #{glyphs.size} but got one of size #{group.size}.  squares = #{group.inspect}" if group.size != glyphs.size 
      @groups ||= []
      @groups << group unless @groups.include?(group)
    end

  end
end
