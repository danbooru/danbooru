# frozen_string_literal: true

# The Danbooru module contains miscellaneous global helper functions.
module Danbooru
  module EnumerableMethods
    extend self

    # Sort a list of strings in natural order, e.g. with "file-2.txt" before "file-10.txt".
    #
    # @see https://en.wikipedia.org/wiki/Natural_sort_order
    # @see https://stackoverflow.com/a/15170063
    #
    # @param list [Enumerable<String>] The list to sort.
    # @return [Array] The sorted list.
    def natural_sort(list)
      natural_sort_by(list, &:to_s)
    end

    # Sort a list of objects in natural order. The block should return a sort key, which is compared in natural order.
    #
    # @param list [Enumerable<Object>] The list to sort.
    # @return [Array] The sorted list.
    def natural_sort_by(list, &block)
      list.sort_by do |element|
        # "file-2022-10-01.txt" => ["file-", 2022, "-", 10, "-", 1, ".txt"]
        yield(element).to_s.split(/(\d+)/).map { |str| str.match?(/\A\d+\z/) ? str.to_i : str }
      end
    end
  end

  extend EnumerableMethods
end
