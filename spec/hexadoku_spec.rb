require 'backports' unless defined? require_relative
require_relative 'spec_helper'

describe Doku::Hexadoku do
  it 'has the upper-case glyph characters' do
    Doku::Hexadoku.glyph_chars.should == %w{0 1 2 3 4 5 6 7 8 9 A B C D E F}
  end

  it 'rejects invalid glyphs in glyph_char' do
    lambda { Doku::Hexadoku.glyph_char(19) }.should raise_error ArgumentError, "Invalid glyph 19."
  end

  it 'rejects invalid characters in glyph_parse' do
    lambda { Doku::Hexadoku.glyph_parse('H') }.should raise_error ArgumentError, "Invalid character 'H'."
  end

  it 'accepts both cases in glyph_parse' do
    Doku::Hexadoku.glyph_parse('d').should == 0xD
    Doku::Hexadoku.glyph_parse('D').should == 0xD
  end

  it 'rejects invalid characters in the constructor' do
    grid_string = <<END
ABCD|....|....|....
....|abcd|....|....
X...|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
END
    lambda { Doku::Hexadoku.new(grid_string) }.should raise_error ArgumentError, "Line 2, character 0: Invalid character 'X'.  Expected period (.) or glyph (0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F)."
  end

  it 'accepts lower-case or upper-case in the consturctor' do
    grid_string = <<END.strip
ABCD|....|....|....
....|abcd|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
----+----+----+----
....|....|....|....
....|....|....|....
....|....|....|....
....|....|....|....
END
    Doku::Hexadoku.new(grid_string).to_s.should == grid_string.upcase
  end
end
