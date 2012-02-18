$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', 'lib'
require 'rspec'
require 'doku'

Sudoku = Doku::Sudoku
Hexadoku = Doku::Hexadoku
Hexamurai = Doku::Hexamurai
DancingLinks = Doku::DancingLinks
