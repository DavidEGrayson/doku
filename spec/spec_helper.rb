$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', 'lib'
require 'rspec'
require 'doku'

# Allows us to use short class names in the specs:
Sudoku = Doku::Sudoku
Hexadoku = Doku::Hexadoku
Hexamurai = Doku::Hexamurai
