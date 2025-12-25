# frozen_string_literal: true

# This class contains custom extensions to the standard library Enumerable class.
#
# @see config/initializers/core_extensions.rb
# @see https://ruby-concurrency.github.io/concurrent-ruby/master/file.promises.out.html
module Danbooru
  module Enumerable
    # Like `#each`, but perform the block on each item in parallel. Note that items aren't processed in order, so things
    # like `parallel_each.map` that rely on ordering won't work.
    def parallel_each(executor = :io, &block)
      return enum_for(:parallel_each, executor) unless block_given?

      parallel_map(executor, &block)
      self
    end

    # Like `#map`, but in parallel.
    def parallel_map(executor = :io, &block)
      return enum_for(:parallel_map, executor) unless block_given?

      promises = map do |item|
        Concurrent::Promises.future_on(executor, item, &block)
      end

      Concurrent::Promises.zip_futures_on(executor, *promises).value!
    end
  end
end
