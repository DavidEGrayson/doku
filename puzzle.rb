class Puzzle
  attr_accessor :symbols
  attr_accessor :symbol_strings
  attr_accessor :squares
  attr_accessor :groups

  def initialize
    @symbols = []
    @squares = []
    @groups = []
  end
end

class Square
  attr_accessor :x
  attr_accessor :y
  attr_accessor :line_number
  attr_accessor :char_number
  attr_accessor :given_value

  def initialize(x, y, line_number, char_number)
    @x, @y, @line_number, @char_number = x, y, line_number, char_number
  end
end
