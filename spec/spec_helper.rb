$LOAD_PATH.unshift File.join File.dirname(__FILE__), '..', 'lib'
require 'rspec'
require 'doku'

# Change this to true if a test is failing and you want more clues about why.
EXTRA_ASSERTS = false

if EXTRA_ASSERTS
  # Add any patches here that help check the validity of the algorithm but are
  # not necessary to have in the production code.

  class Doku::DancingLinks::LinkMatrix::Column
    def size=(num)
      raise "bad class" unless Fixnum === num
      raise "negative value #{num}" if num < 0
      @size = num
    end
  end
end
