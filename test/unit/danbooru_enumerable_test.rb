require "test_helper"

class DanbooruEnumerableTest < ActiveSupport::TestCase
  context "Danbooru::Enumerable" do
    context "#parallel_each method" do
      should "not deadlock when using our default thread pool settings (limited threads and no queueing)" do
        assert_nothing_raised do
          Danbooru.config.stubs(:max_concurrency).returns(4)

          Timeout.timeout(3.seconds) do
            128.times.parallel_each do
              8.times.parallel_each do
                4.times.parallel_each do
                  # do nothing
                end
              end
            end
          end
        end
      end

      should "deadlock when using a thread pool with a limited number of threads and unlimited queueing" do
        assert_raises(Timeout::Error) do
          executor = Concurrent::ThreadPoolExecutor.new(max_threads: 4)

          Timeout.timeout(3.seconds) do
            128.times.parallel_each(executor) do
              8.times.parallel_each(executor) do
                4.times.parallel_each(executor) do
                  # do nothing
                end
              end
            end
          end
        end
      end

      should "process items in parallel" do
        time = Benchmark.realtime do
          array = []

          10.times.parallel_each do |i|
            sleep(0.11)
            array << i
          end

          assert_not_equal(10.times.to_a, array)
          assert_equal(10.times.to_a, array.sort)
        end

        assert(time < 1.second)
      end
    end

    context "#parallel_map method" do
      should "process items in parallel" do
        time = Benchmark.realtime do
          array = 10.times.parallel_map do |i|
            sleep(0.11)
            i
          end

          assert_equal(10.times.to_a, array)
        end

        assert(time < 1.second)
      end

      should "not start any more items after an item fails" do
        executor = Concurrent::ThreadPoolExecutor.new(max_threads: 2, max_queue: 0, synchronous: true, fallback_policy: :caller_runs)
        started = Concurrent::AtomicFixnum.new

        error = assert_raises(Concurrent::MultipleErrors) do
          100.times.parallel_map(executor) do
            started.increment
            sleep(0.01)
            raise ArgumentError, "failed"
          end
        end

        assert_operator(started.value, :<=, 3)
        assert_equal(started.value, error.errors.size)
        assert(error.errors.all?(ArgumentError))
      end

      should "raise the error when only one item fails" do
        error = assert_raises(ArgumentError) do
          10.times.parallel_map do |i|
            raise ArgumentError, "failed" if i == 0
            i
          end
        end

        assert_equal("failed", error.message)
      end
    end
  end
end
