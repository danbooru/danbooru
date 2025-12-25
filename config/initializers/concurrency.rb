# frozen_string_literal: true

# Hack to configure the thread pool used by promises (Concurrent::Promise) in the concurrent-ruby gem.
#
# We set the maximum number of threads to `Danbooru.config.max_concurrency`, and we disable queueing
# so that if we try to schedule more tasks than there are available threads, then the tasks are
# worked by the current thread instead of being queued up, which can potentially cause deadlocks.
#
# https://ruby-concurrency.github.io/concurrent-ruby/master/file.thread_pools.html
module Concurrent
  # This is the default executor used by promises.
  def self.new_io_executor(**options)
    if Danbooru.config.max_concurrency.to_i <= 0
      return ImmediateExecutor.new
    end

    # https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/ThreadPoolExecutor.html
    ThreadPoolExecutor.new(
      name: "io",
      min_threads: 0,
      max_threads: Danbooru.config.max_concurrency.to_i,
      max_queue: 0,
      idletime: 60,
      synchronous: true,
      fallback_policy: :caller_runs,
    )
  end

  def self.new_fast_executor(**options)
    if Danbooru.config.max_concurrency.to_i <= 0
      return ImmediateExecutor.new
    end

    ThreadPoolExecutor.new(
      name: "fast",
      min_threads: 0,
      max_threads: Danbooru.config.max_concurrency.to_i,
      max_queue: 0,
      idletime: 60,
      synchronous: true,
      fallback_policy: :caller_runs,
    )
  end
end
