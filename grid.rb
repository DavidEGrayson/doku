module PuzzleOnGrid
  Separators = %w{- + |}

  attr_accessor :glyph_strings
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

        if char == '.' || glyph_strings.include?(char)
          @squares << square = Square.new
          square.extend SquareOnGrid
          square.x = x
          square.y = y
          square.line_number = line_number
          square.char_number = char_number

          if glyph_strings.include? char
            square.given_value = glyphs[glyph_strings.index char]
          end
        end
        x += 1
      end
      y += 1
    end
  end
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

  def inspect
    "SquareOnGrid(#@x, #@y)"
  end
end

