require_relative 'spec_helper'

Hexamurai = Doku::Hexamurai

describe 'Hexamurai class' do
  it 'has 768 squares' do
    Hexamurai.squares.size.should == 768
  end

  it 'has 16 squares in the first row' do
    first_row = Hexamurai.squares.select { |s| s.matches?(y:0) }
    first_row.size.should == 16
  end

  it 'has 16 squares in the first column of the top hexadoku' do
    first_row = Hexamurai.squares.select { |s| s.matches? x:8, y:(0..15) }
  end

  it 'has the right number of groups' do
    # A hexadoku has 3*16 groups (16 columns, 16 rows, 16 boxes)
    # There are 5 hexadokus.
    # The reckoning above counted the 32 rows and columns of the 
    # center hexadoku twice, and counted the 16 boxes of the
    # center hexaodoku thrice, so subtract 64.
    # There are 2*16 inferred groups (16 columns, 16 rows).
    Hexamurai.groups.size.should == 5*3*16 - 64 + 2*16
  end

  it 'has valid line and char numbers' do
    lines = Hexamurai.template.split("\n")
    Hexamurai.squares.each do |square|
      line = lines[square.line_number]
      line.should_not be_nil
      line.size.should > square.char_number
    end
  end
end
