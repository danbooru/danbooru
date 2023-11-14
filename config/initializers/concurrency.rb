# frozen_string_literal: true

# Hack to set the max thread pool size used by promises (Concurrent::Promise) in the concurrent-ruby gem.
Concurrent::ThreadPoolExecutor.const_set(:DEFAULT_MAX_POOL_SIZE, Danbooru.config.max_concurrency.to_i)
