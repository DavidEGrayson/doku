require_relative 'puzzle'
require_relative 'grid'

class Sudoku < Puzzle
  include PuzzleOnGrid

  def initialize(initial_view)
    @initial_view = initial_view
    @glyphs = (1..9).to_a
    @glyph_chars = @glyphs.collect { |s| s.to_s }
    parse_initial_view
    define_groups
  end

  def define_groups
    0.upto(8) do |n|
      define_group x:n
      define_group y:n
    end

    0.step(8,3).each do |start_x|
      0.step(8,3).each do |start_y|
        define_group(x:start_x...(start_x+3), y:start_y...(start_y+3))
      end
    end
  end
end
