module Doku
  # This module is meant to be included in subclasses of {Puzzle} where the
  # squares are arranged in a grid.
  #
  # The {Puzzle} class contains only very abstract code, dealing with
  # the abstract concepts of {Puzzle.squares squares},
  # {Puzzle.glyphs glyphs}, and {Puzzle.groups groups}.
  # The {Puzzle} class can represent a wide variety of puzzles, including
  # three-dimensional puzzles or puzzles that don't have any particular
  # spatial arrangement.
  # However, most of the puzzles we are interested in studying are arranged
  # in a grid, and this module contains code that makes it easy to define
  # and work with those puzzles.
  #
  # Every {Puzzle.squares square} in a {PuzzleOnGrid} puzzle is a
  # {SquareOnGrid} with x and y coordinates to represent its position on the grid.
  # The x coordinate is 0 for the first row, 1 for the second row, etc.
  # The y coordinate is 0 for the first column, 1 for the second column, etc.
  #
  # See the {ClassMethods} module for the class methods that are added to each
  # class that includes PuzzleOnGrid.
  module PuzzleOnGrid
    # These are the separators that can appear in the {ClassMethods#template template}
    # string or the string argument to the {#initialize} to make it more readable.
    Separators = ['-', '+', '|']

    private
    def self.included(klass)
      klass.extend ClassMethods
    end

    def self.parse_grid_string(string)
      y = 0
      string.lines.each_with_index do |line, line_number|
        line.chomp!
        next if (line.chars.to_a - Separators).empty?

        x = 0
        line.chars.each_with_index do |char, char_number|
          next if Separators.include?(char)

          yield char, char_number, line_number, x, y

          x += 1
        end
        y += 1
      end
    end
    public

    module ClassMethods
      # @return (Array) Array with the line number and character number
      #   of the given square in the {#template} string.
      def coordinates_in_grid_string(square)
        [@line_number[square.y], @char_number[square.x]]
      end

      # This is a multi-line string that defines all the squares in the puzzle and the
      # {Separators} to use to make the puzzle more readable in {#to_grid_string}.
      # A period character ('.') represents a square.
      # This is defined in the class by using the {#has_template} method.
      # @return (String) The template string from the class definition.
      attr_reader :template

      # This is an array of characters (strings of length 1) which are used in
      # multi-line grid strings to represent {Puzzle.glyphs glyphs} in a square.
      # The order of this array must correspond to the order of the {Puzzle.glyphs glyphs}.
      # For example, for {Sudoku}, this is
      # ['1', '2', '3', '4', '5', '6', '7', '8', '9'].
      # This is defined in the class definition using the {#has_glyph_chars} method.
      # @return (Array) Array of characters.
      attr_reader :glyph_chars
      
      # Selects all the squares in this puzzle which match
      # the specified condition.
      # @param conditions (Hash) See {SquareOnGrid#matches?}.
      # @return (Array) Array of squares.
      def squares_matching(conditions)
        squares.select { |sq| sq.matches? conditions }
      end

      # Selects all the squares in this puzzle that are within a certain
      # square area on the grid.
      # @param leftmost_x (Integer) The x coordinate of the left-most column in the square area.
      # @param top_y (Integer) The y coordinate of the top-most row in the square area.
      # @param size (Integer) The width and height of the square.
      # @return (Array) Array of squares.
      def square_group(leftmost_x, top_y, size=Math.sqrt(glyphs.size))
        squares_matching :x => leftmost_x...(leftmost_x+size), :y => top_y...(top_y+size)
      end

      # Selects some squares with a specific y coordinate.
      # @param leftmost_x (Integer) The x coordinate of the left-most square.
      # @param size (Integer) The width of the row.
      # @return (Array) Array of squares.
      def row(y, leftmost_x=0, size=glyphs.size)
        squares_matching :x => leftmost_x...(leftmost_x+size), :y => y
      end

      # Selects some squares with a specific x coordinate.
      # @param top_y (Integer) The y coordinate of the top-most square.
      # @param size (Integer) The height of the column.
      # @return (Array) Array of squares.
      def column(x, top_y=0, size=glyphs.size)
        squares_matching :x => x, :y => top_y...(top_y+size)
      end

      # @return (String) The character that represents the given {Puzzle.glyphs glyph}.
      def glyph_char(glyph)
        glyph_chars.at(glyphs.index(glyph) || (raise ArgumentError, "Invalid glyph #{glyph}."))
      end

      # @return (Object) The {Puzzle.glyphs glyph} represented by the given character.
      def glyph_parse(char)
        glyphs.at(glyph_chars.index(char.upcase) || (raise ArgumentError, "Invalid character '#{char}'."))
      end

      private

      # This is called in the class definition to define the {#template} string,
      # thus defining which squares are in the puzzle.
      def has_template(string)
        @template = string.freeze
        define_squares_from_template
      end

      # This is called in the class definition to define the {#glyph_chars}.
      # This function converts the characters to upper case to make it
      # easier to parse strings provided by the user in a case insensitive way.
      def has_glyph_chars(chars)
        @glyph_chars = chars.collect &:upcase
      end

      def define_square_on_grid(x, y, line_num, char_num)
        define_square SquareOnGrid.new x, y

        @line_number ||= []
        @char_number ||= []
        @line_number[y] = line_num
        @char_number[x] = char_num
      end

      # Using the {#template} provided for the puzzle, this method
      # defines objects to represent each of the different squares.
      def define_squares_from_template
        PuzzleOnGrid.parse_grid_string(template) do |char, char_number, line_number, x, y|
          if char == '.'
            define_square_on_grid x, y, line_number, char_number
          end
        end
      end
    end

    # Creates a new instance of the puzzle.
    # @param grid_string (String) A multi-line string defining which glyphs are
    #   currently written in which squares.  You can use {Separators}
    #   to make this string more readable.
    #   This parameter is provided to make it easy to manually type in puzzles.
    #   If you are not typing the puzzle in, you should probably use {#set} instead.
    #   A good way to type this string is to copy the class's
    #   {ClassMethods#template template} and replace some of the periods with
    #   {ClassMethods#glyph_chars glyph_chars} (e.g. replace a '.' with '3').
    def initialize(grid_string=nil)
      super()
      parse_initial_grid_string grid_string if grid_string
    end

    # @return (String) A multi-line string representation of the puzzle suitable
    #   for displaying, based on the {ClassMethods#template template}.
    def to_grid_string
      lines = self.class.template.split("\n")
      each do |square, glyph|
        line_number, char_number = self.class.coordinates_in_grid_string square
        lines[line_number][char_number] = self.class.glyph_char glyph
      end
      lines.join "\n"
    end

    # Assigns a glyph to a square.
    # This will modify the state of the puzzle, overwriting the previous
    # glyph assignment.
    # @param x (Integer) The x coordinate of the square.
    # @param y (Integer) The y coordinate of the square.
    # @param glyph The {Puzzle.glyphs glyph} to assign to that square, or nil.
    def set(x, y, glyph)
      self[SquareOnGrid.new(x, y)] = glyph
    end

    # Gets the glyph assignment for a given square.
    # @param x (Integer) The x coordinate of the square.
    # @param x (Integer) The y coordinate of the square.
    # @return (Object) The {Puzzle.glyphs glyph} assigned to that square, or nil if
    #   none is assigned.
    def get(x, y)
      self[SquareOnGrid.new(x, y)]
    end

    # @return (String) The same as {#to_grid_string}.
    def to_s
      to_grid_string
    end

    private
    def parse_initial_grid_string(grid_string)
      PuzzleOnGrid.parse_grid_string(grid_string) do |original_char, char_number, line_number, x, y|
        square = SquareOnGrid.new(x, y)

        char = original_char.upcase

        if !squares.include?(square)
          raise "Line #{line_number}, character #{char_number}: Invalid character.  Expected space." if char != ' '
        elsif char == '.'
          # No glyph specified for this square.
        elsif self.class.glyph_chars.include?(char)
          self[square] = self.class.glyph_parse(char)
        else
          raise ArgumentError, "Line #{line_number}, character #{char_number}: Invalid character '#{original_char}'.  Expected period (.) or glyph (#{self.class.glyph_chars.join ','})."
        end
      end
    end
  end

  # Represents a square on a grid.
  # Any two instances with the same x and y coordinates are considered
  # to be equal, which makes it convenient to use SquareOnGrid instances
  # as a  key in a hash table.
  # This class is used by the {PuzzleOnGrid} module to represent the
  # {Puzzle.squares squares} in grid-based {Puzzle}s.
  class SquareOnGrid < Struct.new(:x, :y)
    # @param conditions (Hash)  Should be a hash where the keys are
    #  :x or :y and the values are either Integers or Integer ranges.
    # @return (Boolean) True if the square matches all the conditions.
    def matches?(conditions)
      conditions.each do |property, values|
        return false unless values === send(property)
      end
      return true
    end

    def to_s
      "Square(#{x}, #{y})"
    end
  end
end
