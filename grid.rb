module PuzzleOnGrid
  Separators = %w{- + |}

  attr_accessor :glyph_chars
  attr_accessor :initial_view

  def glyph_char(glyph)
    raise ArgumentError, "Invalid glyph #{glyph}" unless glyphs.index glyph
    glyph_chars[glyphs.index glyph]
  end

  def glyph_parse(char)
    glyphs[glyph_chars.index char]
  end

  def parse_initial_view
    @squares = []

    y = 0
    initial_view.lines.each_with_index do |line, line_number|
      line.chomp!
      next if (line.chars.to_a - Separators).empty?

      x = 0
      line.chars.each_with_index do |char, char_number|
        next if Separators.include?(char)

        if char == '.' || glyph_chars.include?(char)
          @squares << square = Square.new
          square.extend SquareOnGrid
          square.x = x
          square.y = y
          square.line_number = line_number
          square.char_number = char_number

          if glyph_chars.include? char
            square.given_glyph = glyph_parse char
          end
        end
        x += 1
      end
      y += 1
    end
  end

  def glyph_state_to_string(glyph_state)
    lines = initial_view.split("\n")
    glyph_state.each do |square, glyph|
      next if glyph.nil?
      lines[square.line_number][square.char_number] = glyph_char glyph
    end
    lines.join "\n"
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

  def to_s
    "Square(#@x, #@y)"
  end
end

