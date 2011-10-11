%w{grid group hexadoku puzzle sudoku solver}.each do |file|
  require_relative "../#{file}.rb"
end
