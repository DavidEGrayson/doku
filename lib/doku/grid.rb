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
  module PuzzleOnGrid
    # These are the separators that can appear in the {ClassMethods#template template} string
    # to make it more readable.
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
      def coordinates_in_grid_string(square)
        [@line_number[square.y], @char_number[square.x]]
      end

      def template
        @template
      end

      def glyph_chars
        @glyph_chars
      end
      
      def squares_matching(conditions)
        squares.select { |sq| sq.matches? conditions }
      end

      def square_group(leftmost_x, top_y, size=Math.sqrt(glyphs.size))
        squares_matching :x => leftmost_x...(leftmost_x+size), :y => top_y...(top_y+size)
      end

      def row(y, leftmost_x=0, size=glyphs.size)
        squares_matching :x => leftmost_x...(leftmost_x+size), :y => y
      end

      def column(x, top_y=0, size=glyphs.size)
        squares_matching :x => x, :y => top_y...(top_y+size)
      end

      private

      def has_template(string)
        @template = string.freeze
        define_squares_from_template
      end

      def has_glyph_chars(chars)
        @glyph_chars = chars
      end

      def define_square_on_grid(x, y, line_num, char_num)
        define_square SquareOnGrid.new x, y

        @line_number ||= []
        @char_number ||= []
        @line_number[y] = line_num
        @char_number[x] = char_num
      end

      # Using the template provided for the puzzle, this function
      # defines objects to represent each of the different squares.
      def define_squares_from_template
        PuzzleOnGrid.parse_grid_string(template) do |char, char_number, line_number, x, y|
          if char == '.'
            define_square_on_grid x, y, line_number, char_number
          end
        end
      end
    end

    def initialize(grid_string=nil)
      super()
      parse_initial_grid_string grid_string if grid_string
    end

    def glyph_chars
      self.class.glyph_chars
    end

    def glyph_char(glyph)
      raise ArgumentError, "Invalid glyph #{glyph}" unless glyphs.index glyph
      glyph_chars[glyphs.index glyph]
    end

    def glyph_parse(char)
      glyphs[glyph_chars.index char]
    end

    def parse_initial_grid_string(grid_string)
      PuzzleOnGrid.parse_grid_string(grid_string) do |char, char_number, line_number, x, y|
        square = SquareOnGrid.new(x, y)

        if square.nil?
          raise "Line #{line_number}, character #{char_number}: Invalid character.  Expected space." if char != ' '
        elsif char == '.'
          # No glyph specified for this square.
        elsif glyph_chars.include?(char)
          self[square] = glyph_parse(char)
        else
          raise "Line #{line_number}, character #{char_number}: Invalid character.  Expected period (.) or glyph (#{glyph_chars})." if square.nil?
        end
      end
    end

    def to_grid_string
      lines = self.class.template.split("\n")
      each do |square, glyph|
        line_number, char_number = self.class.coordinates_in_grid_string square
        lines[line_number][char_number] = glyph_char glyph
      end
      lines.join "\n"
    end

    def set(x, y, glyph)
      self[SquareOnGrid.new(x, y)] = glyph
    end

    def get(x, y)
      self[SquareOnGrid.new(x, y)]
    end

    def to_s
      to_grid_string
    end
  end

  class SquareOnGrid < Struct.new(:x, :y)
    def matches?(args)
      args.each do |property, values| 
        return false unless values === send(property)
      end
      return true
    end

    def to_s
      "Square(#{x}, #{y})"
    end
  end
end
