require 'backports' unless defined? require_relative
require_relative 'spec_helper'
require 'nokogiri'

describe Doku::PuzzleOnGrid::Svg do
  before do
    @puzzle = Doku::Sudoku.new
  end

  it "can return a string svg" do
    str = @puzzle.to_svg
    File.open("tmphax.svg","w") { |f| f.write str }
    lines = str.split("\n")
    lines[0].should == %q{<?xml version="1.0" encoding="UTF-8"?>}

    doc = Nokogiri::XML(str)

    # <!DOCTYPE svg>
    doctype = doc.children.first
    doctype.should be_a_kind_of Nokogiri::XML::DTD
    doctype.name.should == "svg"

    svg = doctype.next
    svg = doc.css("svg").first
    svg.should be_a_kind_of Nokogiri::XML::Element
    svg.name.should == "svg"
    svg.attr("width").to_i.should == 500   # tmphax
    svg.attr("height").to_i.should == 500  # tmphax
  end
end
