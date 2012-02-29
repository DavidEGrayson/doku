module Doku; end
module Doku::PuzzleOnGrid; end

module Doku::PuzzleOnGrid::Svg
  Style = <<END
line {
  stroke: #000;
  stroke-width: 1px;
}
END

  SquareWidth = 40

  def to_svg
    builder = self.class.build_svg_grid

    builder.to_s
  end

  module ClassMethods
    def build_svg_grid
      require 'builder'

      width = 500
      height = 500

      builder = Builder::XmlMarkup.new :indent=>2
      builder.instruct!
      builder.declare! :DOCTYPE, :svg
      builder.svg(:xmlns => "http://www.w3.org/2000/svg",
                  :'xmlns:xlink' => "http://www.w3.org/1999/xlink",
                  :width => width, :height => height) do
        builder.defs do
          builder.style Style
        end
      end
    end
  end

end
