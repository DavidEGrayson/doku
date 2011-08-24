module DancingLinks
  class LinkEnumerator
    include Enumerable
    def initialize(link, start, termination=start)
      @link = link
      @start = start
      @termination = termination
    end

    def each
      n = @start
      while true
        yield n
        n = n.send(@link)
        return nil if n == @termination
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

      def initialize(id)
        @up = @down = self
        @id = id
      end
    end

    class SparseMatrix::Node
      include HorizontalLinks
      include VerticalLinks

      attr_reader :column

      def intialize(column)
        @column = column
        self.up = column.up
        self.down = column
        reinsert
      end

      def reinsert
        up.down = down.up = self
      end
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

    def find_or_create_column(id)
      @columns[id] || create_column(id)
    end

    def create_column(id)
      column = Column.new(id)
      column.insert_left self
      @column_count += 1
      return @columns[id] = column
    end

    def self.from_sets(rows)
      rows.each_with_object(new) do |row, sparse_matrix|
        sparse_matrix.add_row row
      end
    end

    # row is an Enumerable of column_ids.
    # If a column_id is not recognized, it will be added to the matrix
    # as a new column.
    def add_row(row)
      first_node = nil
      last_node = nil
      row.each do |column_id|
        column = find_or_create_column(column_id)
        node = Node.new(column)
        if first_node.nil?
          first_node = node.left = node.right = node
        else
          node.insert_right last_node
        end
        last_node = node
      end
    end
  end
end
