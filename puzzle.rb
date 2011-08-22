require_relative 'group'

class Puzzle
  attr_accessor :glyphs
  attr_accessor :squares
  attr_accessor :groups

  def define_group(args)
    s = if args.is_a? Hash
      squares.select { |sq| sq.matches? args }
    else
      args.dup
    end

    raise ArgumentError, "Expected groups to be of size #{glyphs.size} but got one of size #{s.size}.  squares = #{s.inspect}" if s.size != glyphs.size 
    @groups ||= []
    @groups << Group.new(s)
  end

  # There are several ways to infer new groups from the ones
  # already defined, but here is one:
  #   Suppose A, B, and C are groups.
  #   If the A and B are disjoint and C is a subset of A+B, then
  #   (A+B)-C can be inferred as a group.
  # This function detects such triplets (A, B, C) with the added
  # condition that A-C and B-C are the same size.
  def infer_groups
    inferred_groups = []
    groups.each do |groupC|
      candidates = groups.select { |g| g.intersection(groupC).size == glyphs.size/2 }
      candidates.each do |groupA|
        candidates.each do |groupB|
          next if groupB == groupA

          union = groupA + groupB
          if groupC.subset? union
            inferred_groups << union - groupC
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
