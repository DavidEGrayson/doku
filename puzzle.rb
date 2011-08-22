require_relative 'group'

class Puzzle
  attr_accessor :symbols
  attr_accessor :squares
  attr_accessor :groups

  def define_group(args)
    if args.is_a? Hash
      define_group squares.select { |s| s.matches? args }
    else
      squares = args.dup
      raise ArgumentError, "Expected groups to be of size #{symbols.size} but got one of size #{group.size}.  squares = #{squares.inspect}" if squares.size != symbols.size 
      @groups ||= []
      @groups << Group.new(squares)
    end
  end
end

class Square
  attr_accessor :given_value
end
