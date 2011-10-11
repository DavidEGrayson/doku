require_relative 'group'

class Puzzle
  private

  def self.has_glyphs(glyphs)
    @glyphs = glyphs
  end

  def self.define_square(square)
    raise ArgumentError, "square should not be nil" if square.nil?
    @squares ||= []
    @squares << square
  end

  def self.has_squares(squares)
    raise ArgumentError, "list of squares should not contain nil" if squares.include? nil
    @squares = squares.uniq
  end

  public

  def initialize
    @glyph_state ||= {}
  end

  def initialize_copy(source)
    super
    @glyph_state = @glyph_state.dup
  end

  def self.glyphs
    raise "glyphs not defined for #{self}" if !defined?(@glyphs)
    @glyphs
  end

  def self.squares
    raise "squares not defined for #{self}" if !defined?(@glyphs)
    @squares
  end

  def self.groups
    raise "groups not defined for #{self}" if !defined?(@groups)
    @groups
  end

  def glyphs
    self.class.glyphs
  end

  def squares
    self.class.squares
  end

  def groups
    self.class.groups
  end

  attr_reader :glyph_state

  def [](square)
    raise IndexError, "Key must be a square in this puzzle." if !squares.include?(square)
    @glyph_state[square]
  end

  def []=(square, glyph)
    raise IndexError, "Key must be a square in this puzzle." if !squares.include?(square)
    raise ArgumentError, "Value must be a glyph in this puzzle or nil." if !glyph.nil? && !glyphs.include?(glyph)
    @glyph_state[square] = glyph
  end

  def each(&block)
    @glyph_state.each(&block)
  end

  def glyph_state_to_string(glyph_state)
    glyph_state.inspect
  end

  private
  def self.define_group(args)
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
  def self.infer_groups
    inferred_groups = []
    groups.each do |groupC|
      candidates = groups.select { |g| g.intersection(groupC).size == glyphs.size/2 }
      candidates.each do |groupA|
        candidates.each do |groupB|
          break if groupB == groupA

          g = groupA + groupB - groupC
          inferred_groups << g if g.size == glyphs.size
        end
      end
    end

    @groups += inferred_groups
  end
end

class Square
end
