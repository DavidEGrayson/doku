%w{hexadoku sudoku}.each do |file|
  require_relative "../#{file}.rb"
end

# Allows us to use short class names in the specs:
Sudoku = Doku::Sudoku
Hexadoku = Doku::Hexadoku
Hexamurai = Doku::Hexamurai
