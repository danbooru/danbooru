# frozen_string_literal: true

# This class contains custom extensions to the standard library Enumerable class.
#
# @see config/initializers/core_extensions.rb
# @see https://ruby-concurrency.github.io/concurrent-ruby/master/file.promises.out.html
module Danbooru
  module Enumerable
    # Like `#each`, but perform the block on each item in parallel.
    def parallel_each(executor = :io, &block)
      return enum_for(:parallel_each) unless block_given?

      promises = map do |*item|
        Concurrent::Promises.future_on(executor, *item, &block)
      end

      Concurrent::Promises.zip(*promises).wait!
      self
    end
  end
end
