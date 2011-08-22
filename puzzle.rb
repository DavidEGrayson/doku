class Puzzle
  attr_accessor :symbols
  attr_accessor :squares
  attr_accessor :groups

  def define_group(args)
    if args.is_a? Hash
      define_group squares.select { |s| s.matches? args }
    else
      group = args.dup
      raise ArgumentError, "Expected groups to be of size #{symbols.size} but got one of size #{group.size}.  group = #{group.inspect}" if group.size != symbols.size 
      @groups = []
      @groups << group
    end
  end
end

module PuzzleOnGrid
  Separators = %w{- + |}

  attr_accessor :symbol_strings
  attr_accessor :initial_view

  def parse_initial_view
    @squares = []

    y = 0
    initial_view.lines.each_with_index do |line, line_number|
      line.chomp!
      next if (line.chars.to_a - Separators).empty?

      x = 0
      line.chars.each_with_index do |char, char_number|
        next if Separators.include?(char)

        if char == '.' || symbol_strings.include?(char)
          @squares << square = Square.new
          square.extend SquareOnGrid
          square.x = x
          square.y = y
          square.line_number = line_number
          square.char_number = char_number

          if symbol_strings.include? char
            square.given_value = symbols[symbol_strings.index char]
          end
        end
        x += 1
      end
      y += 1
    end
  end
end

class Square
  attr_accessor :given_value
end

module SquareOnGrid
  attr_accessor :x
  attr_accessor :y
  attr_accessor :line_number
  attr_accessor :char_number
  
  def matches?(args)
    args.each do |property, values| 
      return false unless values === send(property)
    end
    return true
  end
end
