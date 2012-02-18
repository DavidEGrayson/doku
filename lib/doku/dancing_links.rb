require 'backports' unless defined?(Enumerator)

module Doku; end

# This module contains a general-purpose implementation of the Dancing Links
# algorithm discovered by Donald Knuth for solving
# {http://en.wikipedia.org/wiki/Exact_cover exact cover problems}.
# This module is included in the Doku gem for convenience, but it really has
# nothing to do with solving Sudoku-like puzzles; it can be applied to any
# exact cover problem.
# The main class in this module is {LinkMatrix}.  All the other classes and
# modules are helpers for this class.
module Doku::DancingLinks
  # The data structures used here are too complicated
  # and interconnected for Ruby to efficiently inspect them.
  # Without this module, even a 7x6 {LinkMatrix} takes
  # many many seconds to inspect.
  module Uninspectable
    # Simply calls to_s.
    # @return (String)
    def inspect
      to_s
    end
  end

  # This is a class that lets us concisely enumerate a certain
  # set of objects by traveling either up, down, left, or right
  # from a starting object until we wrap around and reach that same node.
  # Since this class includes the Enumerable class, it has several fancy
  # methods available with it such as "max_by", "collect", or "to_a".
  class LinkEnumerator
    include Enumerable

    # @param link (Symbol) The link to follow.  Should be :up, :down, :left, or :right.
    # @param start (Object) The starting object.  Typically a {LinkMatrix::Node}, {LinkMatrix::Column} (column header), or {LinkMatrix} (root node).
    # @param include_start (Boolean) True if we want to include the starting object in this enumeration.
    def initialize(link, start, include_start=false)
      @link, @start, @include_start = link, start, include_start
    end

    # Iterates through objects by starting at the starting object
    # and going in the specified direction until the start point is
    # found again.
    # The starting object will be yielded first, if this LinkEnumerator
    # was configured to yield it {#initialize}.
    # @yield (obj)
    def each
      yield @start if @include_start

      n = @start
      while true
        n = n.send @link
        return if n == @start
        yield n
      end
    end
  end

  # This module is mixed into objects to give them their "left"
  # and "right" links, and to give some convenient methods for
  # changing those links.
  # Every class this module is added to gains to attr_accessors:
  # left and right.
  module HorizontalLinks
    include Uninspectable

    def self.included(klass)
      klass.instance_eval do
        attr_accessor :left, :right
      end
    end

    # Removes this object from the horizontal linked list by making the
    # left and right neighbors point at each other instead of this object.
    # This can later be undone with {#reinsert_horizontal}
    def remove_horizontal
      right.left, left.right = left, right
    end

    # Reinserts this object into the horizontal linked list by making the
    # former left and right neighors point to this object instead of each other.
    # The former left and right neighbors are simply found by looking at the
    # "left" and "right" links for this object, which still point to them.
    # This undoes the effect of {#remove_horizontal}.
    def reinsert_horizontal
      left.right = right.left = self
    end

    # Inserts this object to the left of the specified object in the
    # horizontal list.
    def insert_left(obj)
      self.left, self.right = obj.left, obj
      reinsert_horizontal
    end
  end

  # This module is mixed into objects to give them their "up"
  # and "down" links, and to give some convenient methods for
  # changing those links.
  # Every class this module is added to gains to attr_accessors:
  # up and down.
  module VerticalLinks
    include Uninspectable

    def self.included(klass)
      klass.instance_eval do
        attr_accessor :up, :down
      end
    end

    # Removes this object from the vertical linked list by making the
    # up and down neighbors point at each other instead of this object.
    # This can later be undone with {#reinsert_vertical}
    def remove_vertical
      down.up, up.down = up, down
    end

    # Reinserts this object into the vertical linked list by making the
    # former up and down neighors point to this object instead of each other.
    # The former up and down neighbors are simply found by looking at the
    # "up" and "down" links for this object, which still point to them.
    # This undoes the effect of {#remove_vertical}.
    def reinsert_vertical
      up.down = down.up = self
    end

    # Inserts this object above the specified object in the
    # vertical list.
    def insert_above(other)
      self.up, self.down = other.up, other
      reinsert_vertical
    end
  end

  # A LinkMatrix object is the Root object from Donald Knuth's paper on
  # Dancing Links.  It also represents the matrix as a whole, so it has
  # methods for building the matrix and finding exact covers.
  # This data structure is used to efficiently implement Algorithm X,
  # allowing us to find exact covers.
  class LinkMatrix

    # The Column Header object from Knuth.
    # This object represents a requirement that needs to be satisfied
    # at least once in the exact coer problem.
    class Column
      include HorizontalLinks, VerticalLinks

      # An ID object provided by the user to give meaning to the column.
      # This is the N relation from Knuth.
      # The ID can be any object.
      attr_reader :id

      # The current number of nodes in this column.
      # If this is zero, it means the column can not be covered, given
      # choices that have already been made.
      attr_accessor :size

      # Initializes an empty column with the specified id.
      # The ID can be any object.
      def initialize(id)
        @up = @down = self
        @id = id
        @size = 0
      end

      # All the nodes in this column, starting at the top one and going down.
      def nodes_downward
        LinkEnumerator.new :down, self
      end

      # All the nodes in this column, starting at the bottom one and going up.
      def nodes_upward
        LinkEnumerator.new :up, self
      end

      alias :nodes :nodes_downward

      # Covers the column.
      # This algorithm comes from page 6 of Knuth's paper.
      # This operation removes the column from the list of
      # columns that needs to be covered and it removes all
      # rows that would cover this column.
      # This can be efficiently undone with {#uncover}.
      #
      # The word "cover" here means the same thing it does in
      # the phrase "exact cover problem".  Our goal is to
      # cover every column exactly once using this method.
      def cover
        remove_horizontal
        nodes_downward.each do |i|
          i.nodes_except_self_rightward.each do |j|
            j.remove_vertical
            j.column.size -= 1
          end
        end
      end
    
      # Uncovers the column.
      # This algorithm comes from page 6 of Knuth's paper.
      # This operation undoes the effects of {#cover}.
      def uncover
        nodes_upward.each do |i|
          i.nodes_except_self_leftward.each do |j|
            j.column.size += 1
            j.reinsert_vertical
          end
        end
        reinsert_horizontal
      end

      # True if there are no more nodes in this column.
      # @return (Boolean)
      def empty?
        size == 0   # Equivalent to (down == self)
      end
    end

    # This class represents a normal node in Knuth's {#LinkMatrix}.
    # Every node belongs to a column and a row, and it represents the
    # fact that the row (i.e. set) "covers" the column.
    class Node
      include HorizontalLinks, VerticalLinks

      # The {Column} object that this node belongs to.
      attr_accessor :column

      # The user-assigned ID of the row this node belongs to.
      attr_accessor :row_id

      # All nodes in the same row, starting with self and going to the right.
      def nodes_rightward
        LinkEnumerator.new :right, self, true
      end

      # All nodes in the same row, starting with self and going to the right,
      # but not including self.
      def nodes_except_self_rightward
        LinkEnumerator.new :right, self
      end

      # All nodes in the same row, starting with self and going to the left,
      # but not including self.
      def nodes_except_self_leftward
        LinkEnumerator.new :left, self
      end

      alias :nodes_except_self :nodes_except_self_rightward

      # Removes a row from the {LinkMatrix} by covering every
      # column that it touches.  This represents choosing
      # the row to be in our exact cover.
      # This can be done with {#unchoose_row}.
      def cover
        nodes_except_self_rightward.each do |node|
          node.column.cover
        end
      end

      # Undoes the effect of {#choose_row}, putting
      # the nodes of the row back into the {LinkMatrix}.
      def uncover
        nodes_except_self_leftward.each do |node|
          node.column.uncover
        end
      end

    end

    # Since the LinkMatrix object is the root node, it has left and right links.
    include HorizontalLinks

    # Creates a new, empty matrix with no columns and no rows.
    def initialize
      @left = @right = self
      @columns = {}   # column_id object => Column
      @rows = {} # row_id object => Node
    end

    # Enumerable for all the {Column}s in the matrix.
    def columns
      LinkEnumerator.new :right, self
    end

    # True if there are no more columns left in the matrix (they were all covered).
    # @return (Boolean)
    def empty?
      right == self
    end

    # Creates a new column with the specified ID and inserts it
    # into the matrix as the right-most column.
    # @param id (Object) Any object that uniquely identifies the column.
    # @return (Column) Newly created column.
    def create_column(id)
      column = Column.new(id)
      column.insert_left self
      return @columns[id] = column
    end

    # Retrieves a column object by its ID or returns nil if there is
    # no column with that ID.
    # @return (Column)
    def column(id)
      @columns[id]
    end

    # Retrieves a column object by its ID or creates a new one if
    # it didn't exist already.
    # @return (Column)
    def find_or_create_column(id)
      @columns[id] || create_column(id)
    end

    # Creates a new {LinkMatrix} to represent an
    # {http://en.wikipedia.org/wiki/Exact_cover exact cover problem}.
    #
    # Every set in the exact cover problem will be represented by a row in the
    # matrix.
    #
    # Every element in the universe of the exact cover problem will be represented
    # by a column in the matrix.  The universe is inferred by taking the union
    # of all the sets in the sets parameter, but if you want to have control over
    # the order of the columns then you can also make a universe array and
    # pass it in to the universe parameter.
    #
    # In {LinkMatrix}, every row has a row id.  The row id is used to express
    # exact covers when they are found.
    # You can just let all the row ids be equal to the sets themselves by
    # making the sets parameter be an Array or Set of sets, or
    # you can specify the row ids explicitly by if you make the sets parameter
    # be a hash that associates row ids to sets.
    #
    # @param (Object) sets Either a hash associating row_ids to sets, or just
    #   an array of sets.  A set is an Array or Set of objects in the
    #   universe of the exact cover problem.
    # @param universe (Array) This parameter is optional.  If provided, it
    #   will define the order of the first columns of the link matrix.
    #   It is OK if there are elements in the sets that are not present in
    #   this array.
    # @return (LinkMatrix)
    def self.from_sets(sets, universe=[])
      matrix = new
      universe.each do |column_id|
        matrix.find_or_create_column column_id
      end

      if sets.is_a? Hash
        sets.each do |row_id, column_ids|
          matrix.add_row column_ids, row_id
        end
      else
        sets.each do |column_ids|
          matrix.add_row column_ids
        end
      end

      matrix
    end

    # Adds a row to the matrix.
    # If a column_id is not recognized, it will be added to the matrix
    # as a new column.
    #
    # @param column_ids (Enumerable) The column_ids that are in this row.
    # @param row_id (Object) The id of this row.  This is used to express express exact covers and as the argument to {#remove_row}.
    def add_row(column_ids, row_id=column_ids.dup)
      first_node = nil
      column_ids.each do |column_id|
        column = find_or_create_column(column_id)
        node = Node.new

        # Set the vertical links and column.
        node.column = column
        node.insert_above column

        # Set the horizontal links and row_id.
        node.row_id = row_id
        if first_node.nil?
          @rows[row_id] = first_node = node.left = node.right = node
        else
          node.insert_left first_node
        end

        column.size += 1
      end
    end

    # Removes a row from the matrix.
    # @param row_id (Object) The ID of the row that was specified when
    #   {#add_row} was called.
    def remove_row(row_id)
      raise ArgumentError, "Row with id #{row_id} not found." if !@rows[row_id]
      @rows[row_id].nodes_rightward.each do |node|
        node.column.cover
      end
    end

    # This is a recursive method that finds the first exact cover of a
    # LinkMatrix that represents an exact cover problem, using the
    # the algorithm described in Donald Knuth's paper "Dancing Links".
    # This method is just here for purists who want to be sure they are using
    # Donald Knuth's algorithm.
    # For most uses, it is recommended to use the more flexible, non-recursive
    # function {#each_exact_cover} and the methods based on it: {#exact_covers}
    # and {#find_exact_cover}.
    # @return (Array) Array of row_ids of the rows/sets that are in the cover,
    #   or nil if no exact cover was found. 
    def find_exact_cover_recursive(nodes=[])
      if right == self
        # Success.  Matrix is empty because every column is covered.
        return nodes.collect &:row_id
      end

      c = smallest_column
      c.cover

      c.nodes_downward.each do |r|
        nodes.push r

        r.cover

        if answer = find_exact_cover_recursive(nodes)
          # Success
          return answer
        end
        
        r.uncover

        nodes.pop
      end

      c.uncover
      return nil
    end

    # TODO: see if recursive or non-recursive algorithm is faster.

    # Searches for an exact cover.
    # NOTE: This method mutates the LinkMatrix.
    # @return (Array) Array of row ids of the rows/sets that are in the cover,
    #   or nil if no exact cover was found. 
    def find_exact_cover
      exact_covers.first
    end

    # Returns an enumerable that searches for exact covers as its elements
    # are enumerated.
    # NOTE: This method mutates the LinkMatrix.
    # @return (Enumerable) Enumerable of exact covers.  Each exact cover is
    #  an array of row ids of the rows/sets that are in the cover.
    def exact_covers
      Enumerator.new do |y|
        each_exact_cover do |ec|
          y << ec
        end
      end
    end

    # Searches for exact covers and yields them as it finds them.
    # NOTE: This method mutates the LinkMatrix while it is running, but
    #  when it is finished the matrix will be back to its original state.
    # @yield exact_cover (Array)  Array of row_ids of the rows/sets that are
    #   in the cover.
    def each_exact_cover
      nodes = []   # List of nodes that are currently "covered"

      while true

        if empty?
          # Success.  Matrix is empty because every column is covered once.
          yield nodes.collect &:row_id
        end

        if column = choose_column
          # Cover a new column and pick the first node in it.
          column.cover
          node = column.down
        else
          # Uncover columns until we find one with a node we haven't tried.
          node = backtrack!(nodes)
          return if node.nil?  # Tried everything
        end

        # Try the node (push it and cover its columns).
        nodes.push node
        node.cover

      end
    end

    protected

    def choose_column
      return nil if empty?
      column = smallest_column
      return nil if column.empty?
      return column
    end

    # When choosing a column, we use Knuth's S heuristic.
    # Assumption: The matrix has at least one column.
    def smallest_column
      # Slow but concise version of this method:
      #return columns.min_by &:size

      column = smallest = right
      min_size = column.size
      while true
        column = column.right
        return smallest if column == self
        
        if column.size < min_size
          smallest, min_size = column, column.size
          return smallest if min_size == 0
        end
      end
    end

    # This is used by each_exact_cover.
    # Picks the next node to try by back-tracking until we get
    # to a column where we haven't tried all the nodes, uncovering
    # nodes and columns as it goes.
    # Returns nil if we are done searching the entire solution space.
    def backtrack!(nodes)
      while true
        return nil if nodes.empty?  # backtracked back to 0, so we are done
        
        # We tried nodes.last and it didn't work, so
        # pop it off and uncover the corresponding columns.
        node = nodes.pop
        node.uncover
        
        # Try the next node in this column.
        x = node.down

        return x unless x.is_a? Column
        
        # Our downwards iteration has gone full-circle
        # back to the column object where it started.
        x.uncover   # Uncover the column.
      end
    end

  end

end
