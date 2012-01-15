require 'backports' unless defined?(Enumerator)

module DancingLinks
  # The data structures used here are too complicated
  # and interconnected for Ruby to efficiently inspect them.
  # Without this module, even a 7x6 link matrix takes
  # many many seconds to inspect.
  module Uninspectable
    def inspect
      to_s
    end
  end

  class LinkEnumerator
    include Enumerable

    def initialize(link, start, include_start=false)
      @link, @start, @include_start = link, start, include_start
    end

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

  module HorizontalLinks
    include Uninspectable

    def self.included(klass)
      klass.instance_eval do
        attr_accessor :left
        attr_accessor :right
      end
    end

    def remove_horizontal
      right.left, left.right = left, right
    end

    def reinsert_horizontal
      left.right = right.left = self
    end

    def insert_left(obj)
      self.left, self.right = obj.left, obj
      reinsert_horizontal
    end

    def insert_right(obj)
      self.left, self.right = obj, obj.right
      reinsert_horizontal
    end
  end

  module VerticalLinks
    include Uninspectable

    def self.included(klass)
      klass.instance_eval do
        attr_accessor :up
        attr_accessor :down
      end
    end

    def remove_vertical
      down.up, up.down = up, down
    end

    def insert_above(other)
      self.up, self.down = other.up, other
      reinsert_vertical
    end

    def reinsert_vertical
      up.down = down.up = self
    end
  end

  # LinkMatrix object is the Root object from Knuth.
  class LinkMatrix

    # The Column Header object from Knuth.
    class Column
      include HorizontalLinks, VerticalLinks

      # An ID object provided by the user to give meaning to the column.
      # (the N relation from Knuth)
      attr_reader :id

      attr_accessor :size

      def initialize(id)
        @up = @down = self
        @id = id
        @size = 0
      end

      def nodes_downward
        LinkEnumerator.new :down, self
      end

      def nodes_upward
        LinkEnumerator.new :up, self
      end

      alias :nodes :nodes_downward

      # From page 6 of Knuth.
      def cover
        remove_horizontal
        nodes_downward.each do |i|
          i.nodes_except_self_rightward.each do |j|
            j.remove_vertical
            j.column.size -= 1
          end
        end
      end
      
      # From page 6 of Knuth.
      def uncover
        nodes_upward.each do |i|
          i.nodes_except_self_leftward.each do |j|
            j.column.size += 1
            j.reinsert_vertical
          end
        end
        reinsert_horizontal
      end

      def empty?
        size == 0   # Equivalent to (down == self)
      end
    end

    class Node
      include HorizontalLinks, VerticalLinks

      attr_accessor :column
      attr_accessor :row_id

      # All nodes in the row, starting with self.
      def nodes_rightward
        LinkEnumerator.new :right, self, true
      end

      def nodes_except_self_rightward
        LinkEnumerator.new :right, self
      end

      def nodes_except_self_leftward
        LinkEnumerator.new :left, self
      end

      alias :nodes_except_self :nodes_except_self_rightward

      def cover
        nodes_except_self_rightward.each do |node|
          node.column.cover
        end
      end

      def uncover
        nodes_except_self_leftward.each do |node|
          node.column.uncover
        end
      end

    end

    include HorizontalLinks

    def initialize
      @left = @right = self
      @columns = {}   # column_id object => Column
      @rows = {} # row_id object => Node
    end

    def columns
      LinkEnumerator.new :right, self
    end

    def empty?
      right == self
    end

    def create_column(id)
      column = Column.new(id)
      column.insert_left self
      return @columns[id] = column
    end

    def column(id)
      @columns[id]
    end

    def find_or_create_column(id)
      @columns[id] || create_column(id)
    end

    # The column_ids argument is optional.  If provided,
    # it will define the order of the first columns of the link
    # matrix.  If the rows contain elements not present in column_ids,
    # that is OK.
    def self.from_sets(rows, column_ids=[])
      matrix = new
      column_ids.each do |column_id|
        matrix.find_or_create_column column_id
      end

      # TODO: fix to allow Sets or any other enumerable to be passed in too
      if rows.is_a? Array
        rows.each do |column_ids|
          matrix.add_row column_ids
        end
      else
        rows.each do |row_id, column_ids|
          matrix.add_row column_ids, row_id
        end
      end

      matrix
    end

    # row is an Enumerable of column_ids.
    # If a column_id is not recognized, it will be added to the matrix
    # as a new column.
    def add_row(column_ids, row_id=column_ids.dup)
      first_node = nil
      last_node = nil
      column_ids.each do |column_id|
        column = find_or_create_column(column_id)
        node = Node.new
        @rows[row_id] ||= node

        # Set the vertical links and column.
        node.column = column
        node.insert_above column

        # Set the horizontal links and row_id.
        node.row_id = row_id
        if first_node.nil?
          first_node = node.left = node.right = node
        else
          node.insert_right last_node
        end
        last_node = node

        column.size += 1
      end
    end

    def remove_row(row_id)
      raise ArgumentError, "Row with id #{row_id} not found." if !@rows[row_id]
      @rows[row_id].nodes_rightward.each do |node|
        node.column.cover
      end
    end

    # Recursive method of finding the exact cover,
    # from page 5 of Knuth.
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

    def find_exact_cover
      each_exact_cover { |ec| return ec }
      return nil
    end

    def exact_covers
      Enumerator.new do |y|
        each_exact_cover do |ec|
          y << ec
        end
      end
    end

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
      # Slow but concise version of this function:
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
