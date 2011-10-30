%w{hexadoku sudoku}.each do |file|
  require_relative "../#{file}.rb"
end

Sudoku = Doku::Sudoku
Hexadoku = Doku::Hexadoku
Hexamurai = Doku::Hexamurai
