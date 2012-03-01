module Doku; end
module Doku::PuzzleOnGrid; end

module Doku::PuzzleOnGrid::Svg
  Style = <<END
line {
  stroke: #000;
  stroke-width: 0.6px;
}
line.heavy
{
  stroke-width: 2.7px;
}
text {
  dominant-baseline: central;
  text-anchor: middle;
  font-size: 24pt;
  font-family: sans-serif;
}
END

  SquareWidth = 40
  Margin = 3

  def to_svg
    require 'builder'

    abs_max_x = squares.collect(&:x).max
    abs_max_y = squares.collect(&:y).max

    width = (abs_max_x+1)*SquareWidth + Margin*2
    height = (abs_max_y+1)*SquareWidth + Margin*2

    xml_string = ""
    builder = Builder::XmlMarkup.new :target=>xml_string, :indent=>2
    builder.instruct!
    builder.declare! :DOCTYPE, :svg
    builder.svg(:xmlns => "http://www.w3.org/2000/svg",
                :'xmlns:xlink' => "http://www.w3.org/1999/xlink",
                :width => width, :height => height) do
      builder.defs do
        builder.style Style
      end

      builder.g :transform=>"translate(#{Margin}, #{Margin})" do
        (0..(abs_max_x+1)).each do |x|
          left_x = x > 0 ? x - 1 : nil
          right_x = x <= abs_max_x ? x : nil
          xs = [left_x, right_x]
          ys = squares.select { |s| xs.include?(s.x) }.collect(&:y)

          options = {}
          options[:x1] = options[:x2] = x*SquareWidth
          options[:y1] = ys.min*SquareWidth
          options[:y2] = (ys.max+1)*SquareWidth
          if left_x && right_x && self.class.char_number[right_x] - self.class.char_number[left_x] > 1
            options[:class] = "heavy"
          end
          builder.line options
        end

        (0..(abs_max_y+1)).each do |y|
          left_y = y > 0 ? y - 1 : nil
          right_y = y <= abs_max_y ? y : nil
          ys = [left_y, right_y]
          xs = squares.select { |s| ys.include?(s.y) }.collect(&:x)

          options = {}
          options[:y1] = options[:y2] = y*SquareWidth
          options[:x1] = xs.min*SquareWidth
          options[:x2] = (xs.max+1)*SquareWidth
          if left_y && right_y && self.class.char_number[right_y] - self.class.char_number[left_y] > 1
            options[:class] = "heavy"
          end
          builder.line options
        end

        each do |square, glyph|
          builder.text({:x => (square.x+0.5)*SquareWidth, :y => (square.y+0.5)*SquareWidth}, self.class.glyph_char(glyph))
        end
      end
    end

    xml_string
  end

end
