# frozen_string_literal: true

# This class contains custom extensions to the standard library Enumerable class.
#
# @see config/initializers/core_extensions.rb
module Danbooru
  module Enumerable
    class ParallelError < StandardError; end

    # Like `#each`, but perform the block on each item in parallel.
    def parallel_each(**options, &block)
      return enum_for(:parallel_each) unless block_given?

      promises = map do |item|
        Concurrent::Promise.execute(**options) { yield item }
      end

      promises.each(&:wait)

      errors = promises.filter_map(&:reason)
      raise ParallelError, errors.map(&:inspect).join("; "), cause: errors.first if errors.present?

      self
    end
  end
end
