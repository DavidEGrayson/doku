module DancingLinks
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

    def reinsert_vertical
      up.down = down.up = self
    end

    def insert_up(obj)
      self.up, self.down = obj.up, obj
      reinsert_vertical
    end

    def insert_down(obj)
      self.up, self.down = obj, obj.down
      reinsert_vertical
    end
  end

  class SparseMatrix
    class SparseMatrix::Column
      include HorizontalLinks
      include VerticalLinks

      # An ID object provided by the user to give meaning to the column.
      # (the N relation from Knuth)
      attr_accessor :id

      def initialize(id)
        @id = id
        @up = @down = self
      end
    end

    class SparseMatrix::Node
      include HorizontalLinks
      include VerticalLinks
    end

    include HorizontalLinks  # SparseMatrix object is the Root object from Knuth.
    attr_accessor :column_count # TODO: implement

    def initialize
      @left = @right = self
      @columns = {}   # column_id object => SparseMatrixColumn
    end

    def find_or_create_column(id)
      @columns[id] || create_column(id)
    end

    def create_column(id)
      column = Column.new(id)
      column.insert_left self
      return @columns[id] = column
    end

    def self.from_sets(rows)
      sparse_matrix = new
      rows.each do |row|
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
        node.insert_up column
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
