# frozen_string_literal: true

# This class contains custom extensions to the standard library Enumerable class.
#
# @see config/initializers/core_extensions.rb
# @see https://ruby-concurrency.github.io/concurrent-ruby/master/file.promises.out.html
module Danbooru
  module Enumerable
    # Like `#map`, but perform the block on each item in parallel.
    def parallel_map(executor = :io, &block)
      return enum_for(:parallel_map) unless block_given?

      promises = map do |*item|
        Concurrent::Promises.delay_on(executor, *item, &block)
      end

      Concurrent::Promises.zip_futures_on(:immediate, *promises).value!
    end

    # Like `#each`, but perform the block on each item in parallel.
    def parallel_each(executor = :io, &block)
      return enum_for(:parallel_each) unless block_given?

      parallel_map(executor, &block)
      self
    end

    # Iterates the given block for each element with `Concurrent::AtomicBoolean` cancellation flag.
    # If an exception occurs, the flag is set to true and pending elements yield `nil`.
    # The cancellation flag should be checked in each iteration cycle of a loop performing significant work.
    #
    # @see https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/Cancellation.html
    def cancellable(&block)
      return enum_for(:cancellable) unless block_given?

      cancelled = Concurrent::AtomicBoolean.new false

      each do |*item|
        begin
          yield *item, cancelled unless cancelled.true?
        rescue
          cancelled.make_true
          raise
        end
      end
    end
  end
end
