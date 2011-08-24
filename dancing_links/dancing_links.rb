module DancingLinks
  module HorizontalLinks
    def self.included(klass)
      klass.instance_eval do
        attr_accessor :left
        attr_accessor :right
      end
    end
  end

  class SparseMatrix
    include HorizontalLinks  # This object is the Root object.
     
    attr_accessor :columns

    def initialize
      @left = @right = self
      @columns_hash = {}   # column_id object => SparseMatrixColumn
    end

    def self.from_sets(rows)
      rows.each do |row|
        first_node = nil
        last_node = nil
        row.each do |column_id|
          column = add_column_if_needed(column_id)
          node = Node.new(column)
          node.insert_above column
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

end
