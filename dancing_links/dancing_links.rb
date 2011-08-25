module DancingLinks
  class LinkEnumerator
    include Enumerable
    def initialize(link, start, endpoint=start)
      @link, @start, @end = link, start, endpoint
    end

    def each
      n = @start
      while true
        return if n == @end
        yield n
        n = n.send @link
      end
    end
  end

  module HorizontalLinks
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
    class SparseMatrix::Column
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
        LinkEnumerator.new :down, down, self
      end

      def nodes_upward
        LinkEnumerator.new :up, up, self
      end

      alias :nodes :nodes_downward      
    end

    class SparseMatrix::Node
      include HorizontalLinks
      include VerticalLinks

      attr_accessor :column

      # peers does NOT include self; a better name is welcome
      def peers_rightward
        LinkEnumerator.new :right, right, self
      end

      def peers_leftward
        LinkEnumerator.new :left, left, self
      end

      alias :peers :peers_rightward
    end

    include HorizontalLinks
    attr_reader :column_count

    def initialize
      @column_count = 0
      @left = @right = self
      @columns = {}   # column_id object => SparseMatrixColumn
    end

    def columns
      LinkEnumerator.new :right, self.right, self
    end

    def create_column(id)
      column = Column.new(id)
      column.insert_left self
      @column_count += 1
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

      rows.each do |row|
        sparse_matrix.add_row row
      end

      sparse_matrix
    end

    # row is an Enumerable of column_ids.
    # If a column_id is not recognized, it will be added to the matrix
    # as a new column.
    def add_row(row)
      first_node = nil
      last_node = nil
      row.each do |column_id|
        column = find_or_create_column(column_id)
        node = Node.new

        # Set the vertical links and column.
        node.column = column
        node.insert_above column

        # Set the horizontal links.
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
      @column_count -= 1

      column.nodes_downward.each do |i|
        i.peers_rightward.each do |j|
          j.remove_vertical
          j.column.size -= 1
        end
      end
    end

    # From page 6 of Knuth.
    def uncover_column(column)
      @column_count += 1
      raise NotImplementedError
    end
  end
end
