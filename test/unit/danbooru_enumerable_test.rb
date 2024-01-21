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
            128.times.parallel_each(executor: executor) do
              8.times.parallel_each(executor: executor)do
                4.times.parallel_each(executor: executor)do
                  # do nothing
                end
              end
            end
          end
        end
      end
    end
  end
end
