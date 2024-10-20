require 'test_helper'

class DanbooruEnumerableTest < ActiveSupport::TestCase
  context "Danbooru::Enumerable" do
    context "#parallel_each method" do
      should "not deadlock when using our default thread pool settings (limited threads and no queueing)" do
        assert_nothing_raised do
          Danbooru.config.stubs(:max_concurrency).returns(4)

          Timeout.timeout(3.second) do
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

          Timeout.timeout(3.second) do
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
    end

    context "#cancellable method" do
      should "work" do
        Danbooru.config.stubs(:max_concurrency).returns(4)

        e = assert_raises do
          Timeout.timeout(3.second) do
            100.times.parallel_each.cancellable do |n, cancelled|
              100.times do
                next if cancelled.true?
                sleep 1
                raise
              end
            end
          end
        end

        e = e.errors.first if e.is_a?(Concurrent::MultipleErrors)
        assert_instance_of(RuntimeError, e)
      end
    end
  end
end
