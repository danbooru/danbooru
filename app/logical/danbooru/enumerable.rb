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

    # Like `#map`, but in parallel. If an item raises an error, the items that haven't started yet are skipped, and the
    # error is raised after the items that already started finish.
    def parallel_map(executor = :io, &block)
      return enum_for(:parallel_map, executor) unless block_given?

      failed = Concurrent::AtomicBoolean.new

      promises = map do |item|
        Concurrent::Promises.future_on(executor) do
          next if failed.true?

          yield(item)
        rescue StandardError
          failed.make_true
          raise
        end
      end

      Concurrent::Promises.zip_futures_on(executor, *promises).value!
    end
  end
end
