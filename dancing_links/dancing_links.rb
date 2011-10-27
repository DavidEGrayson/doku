module DancingLinks
  # The data structures used here are too complicated
  # and interconnected for Ruby to efficiently inspect them.
  # Without this module, even a 7x6 Sparse Matrix takes
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
      self.up = other.up
      self.down = other
      reinsert_vertical
    end

    def reinsert_vertical
      up.down = down.up = self
    end
  end

  # SparseMatrix object is the Root object from Knuth.
  class SparseMatrix

    # The Column Header object from Knuth.
    class Column
      include HorizontalLinks
      include VerticalLinks

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
    end

    class Node
      include HorizontalLinks
      include VerticalLinks

      attr_accessor :column
      attr_accessor :row_id

      # All nodes in the row, starting with self.
      def row_rightward
        LinkEnumerator.new :right, self, true
      end

      # peers does NOT include self; a better name is welcome
      def peers_rightward
        LinkEnumerator.new :right, self
      end

      def peers_leftward
        LinkEnumerator.new :left, self
      end

      alias :peers :peers_rightward
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
    # it will define the order of the first columns of the sparse
    # matrix.  If the rows contain elements not present in column_ids,
    # that is OK.
    def self.from_sets(rows, column_ids=[])
      sparse_matrix = new
      column_ids.each do |column_id|
        sparse_matrix.find_or_create_column column_id
      end

      if rows.is_a? Array
        rows.each do |column_ids|
          sparse_matrix.add_row column_ids
        end
      else
        rows.each do |row_id, column_ids|
          sparse_matrix.add_row column_ids, row_id
        end
      end

      sparse_matrix
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

    # From page 6 of Knuth.
    def cover_column(column)
      column.remove_horizontal

      column.nodes_downward.each do |i|
        i.peers_rightward.each do |j|
          j.remove_vertical
          j.column.size -= 1
        end
      end
    end

    # From page 6 of Knuth.
    def uncover_column(column)
      column.nodes_upward.each do |i|
        i.peers_leftward.each do |j|
          j.column.size += 1
          j.reinsert_vertical
        end
      end

      column.reinsert_horizontal
    end

    # Recursive method of finding the exact cover,
    # from page 5 of Knuth.
    def find_exact_cover_recursive(nodes=[])
      if right == self
        # Success.  Matrix is empty because every column is covered.
        return nodes.collect &:row_id
      end

      c = choose_column
      cover_column c

      c.nodes_downward.each do |r|
        nodes.push r

        r.peers_rightward.each do |j|
          cover_column j.column
        end

        if answer = find_exact_cover_recursive(nodes)
          # Success
          return answer
        end
        
        r.peers_leftward.each do |j|
          uncover_column j.column
        end

        nodes.pop
      end

      uncover_column c
      return nil
    end

    # TODO: see if recursive or non-recursive algorithm is faster.

    def find_exact_cover
      exact_covers_ { |ec| return ec }
    end

    def exact_covers
      Enumerator.new do |y|
        exact_covers_ do |ec|
          y << ec
        end
      end
    end

    def check_for_success
      if right == self
        # Success.  Matrix is empty because every column is covered.
        yield @nodes.collect &:row_id
        return true
      end
      return false
    end

    def choose_appropriate_column
      column = choose_column
      return nil if column.down == column
      return column
    end

    def exact_covers_(&block)
      @covered_columns = []  # Which columns are currently covered.
      @nodes = []    # columns[i] was covered by the row containing nodes[i].
      while true

        if !check_for_success(&block) && (@column = choose_appropriate_column)
          cover_column @column
          @covered_columns.push @column

          # Try the node (push it and cover its columns).
          @node = @column.down
        else

          # Choose a node to try, back-tracking if necessary.
          while true
            if @covered_columns.empty?
              # We tried all posibilites so we are done now.
              return
            end

            # Go back to previous column and node.
            @column = @covered_columns.last

            # We already tried this node and it didn't work, so
            # pop it off and uncover the corresponding columns.
            @node = @nodes.pop
            @node.peers_leftward.each do |j|
              uncover_column j.column
            end
            
            # Try the next node for this column.
            @node = @node.down

            break unless @node == @column

            # Our downwards iteration has gone full-circle
            # back to the column object where it started.
            # Therefore we have tried all the nodes in this column.
            # Uncover the column and pop it off the list.
            uncover_column @covered_columns.pop
          end

        end

        # Try the node (push it and cover its columns).
        @nodes.push @node
        @node.peers_rightward.each do |j|
          cover_column j.column
        end

      end
    end

    # When choosing a column, we use Knuth's S heuristic.
    # Assumption: The matrix has at least one column.
    def choose_column
      # Slow but concise version of this function:
      #return columns.min_by &:size

      column = smallest_column = right
      min_size = column.size
      while true
        column = column.right
        return smallest_column if column == self
        
        if column.size < min_size
          smallest_column, min_size = column, column.size
          return smallest_column if min_size == 0
        end
      end
    end

    def cover_row(row_id)
      raise ArgumentError, "Row with id #{row_id} not found." if !@rows[row_id]
      @rows[row_id].row_rightward.each do |node|
        cover_column node.column
      end
    end
  end
end
