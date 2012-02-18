require 'backports' unless defined? require_relative
require_relative 'spec_helper'

describe Doku::Hexamurai do
  it 'has 768 squares' do
    Doku::Hexamurai.squares.size.should == 768
  end

  it 'has 16 squares in the first row' do
    first_row = Doku::Hexamurai.squares_matching :y => 0
    first_row.size.should == 16
  end

  it 'has 16 squares in the first column of the top hexadoku' do
    column = Doku::Hexamurai.squares_matching :x => 8, :y => (0..15)
    column.size.should == 16
  end

  it 'has the right number of groups' do
    # A hexadoku has 3*16 groups (16 columns, 16 rows, 16 boxes)
    # There are 5 hexadokus.
    # The reckoning above counted the 16 rows and 16 columns of the 
    # center hexadoku twice (-32), and counted the 16 boxes of the
    # center hexaodoku thrice (-32), so subtract 64.
    # There are 2*16 inferred groups (16 columns, 16 rows).
    Doku::Hexamurai.groups.size.should == (5*3*16 - 64 + 2*16)
  end

  it 'has valid line and char numbers' do
    lines = Doku::Hexamurai.template.split("\n")
    Doku::Hexamurai.squares.each do |square|
      line_number, char_number = Doku::Hexamurai.coordinates_in_grid_string(square)
      line = lines[line_number]
      line.should_not be_nil
      line.size.should > char_number
    end
  end
end
