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

  # Suppose A, B, and C are groups.
  # If the A and B are disjoint and C is a subset of A+B, then
  # (A+B)-C can be inferred as a group.
  def infer_groups
    inferred_groups = []
    groups.each do |groupA|
      groups.each do |groupB|
        break if groupB == groupA

        union = groupA + groupB
        groups.each do |groupC|
          next if groupC == groupA || groupC == groupB

          if groupC.subset? union
            inferred_groups << g = union - groupC
            #puts "Inferred #{g} A=#{groupA.inspect} B=#{groupB.inspect} C=#{groupC.inspect}"
          end
        end
      end
    end

    self.groups += inferred_groups.uniq
  end
end

class Square
  attr_accessor :given_value
end
