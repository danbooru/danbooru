require "test_helper"

class DanbooruMetricTest < ActiveSupport::TestCase
  context "Danbooru::Metric" do
    should "count values for each set of labels in a counter" do
      metric = Danbooru::Metric.new(:requests_total, type: :counter, help: "Requests.", labels: { worker: "1" })
      metric[method: "GET"].increment
      metric[method: "GET"].increment(2)
      metric[method: "POST"].increment

      assert_equal(<<~PROM.chomp, metric.to_prom)
        # HELP requests_total Requests.
        # TYPE requests_total counter
        requests_total{worker="1", method="GET"} 3
        requests_total{worker="1", method="POST"} 1
      PROM
    end

    should "hold the last value set in a gauge" do
      metric = Danbooru::Metric.new(:threads, type: :gauge, help: "Threads.")
      metric.set(5)
      metric.set(3)

      assert_equal("# HELP threads Threads.\n# TYPE threads gauge\nthreads 3", metric.to_prom)
    end

    context "a histogram" do
      setup do
        @metric = Danbooru::Metric.new(:request_duration_seconds, type: :histogram, buckets: [0.1, 1], help: "Request time.", labels: { worker: "1" })
      end

      should "count each observation in every bucket it fits in" do
        @metric.observe(0.05, method: "GET")
        @metric.observe(0.5, method: "GET")
        @metric.observe(5, method: "GET")

        assert_includes(@metric.to_prom, %{request_duration_seconds_bucket{worker="1", method="GET", le="0.1"} 1})
        assert_includes(@metric.to_prom, %{request_duration_seconds_bucket{worker="1", method="GET", le="1"} 2})
        assert_includes(@metric.to_prom, %{request_duration_seconds_bucket{worker="1", method="GET", le="+Inf"} 3})
        assert_includes(@metric.to_prom, %{request_duration_seconds_sum{worker="1", method="GET"} 5.55})
        assert_includes(@metric.to_prom, %{request_duration_seconds_count{worker="1", method="GET"} 3})
      end

      should "count an observation equal to a bucket's bound in that bucket" do
        @metric.observe(0.1)

        assert_includes(@metric.to_prom, %{request_duration_seconds_bucket{worker="1", le="0.1"} 1})
      end

      should "only update the observation's own bucket and the sum" do
        @metric.observe(0.5)

        assert_equal([["1", 1], ["sum", 0.5]], @metric.values.map { |value| [value.labels[:le], value.value] }.sort)
      end

      should "output the buckets, sum, and count in Prometheus format" do
        @metric.observe(5, method: "POST")
        @metric.observe(0.5, method: "GET")

        assert_equal(<<~PROM.chomp, @metric.to_prom)
          # HELP request_duration_seconds Request time.
          # TYPE request_duration_seconds histogram
          request_duration_seconds_bucket{worker="1", method="GET", le="0.1"} 0
          request_duration_seconds_bucket{worker="1", method="GET", le="1"} 1
          request_duration_seconds_bucket{worker="1", method="GET", le="+Inf"} 1
          request_duration_seconds_sum{worker="1", method="GET"} 0.5
          request_duration_seconds_count{worker="1", method="GET"} 1
          request_duration_seconds_bucket{worker="1", method="POST", le="0.1"} 0
          request_duration_seconds_bucket{worker="1", method="POST", le="1"} 0
          request_duration_seconds_bucket{worker="1", method="POST", le="+Inf"} 1
          request_duration_seconds_sum{worker="1", method="POST"} 5
          request_duration_seconds_count{worker="1", method="POST"} 1
        PROM
      end

      should "output no samples if nothing was observed" do
        assert_equal("# HELP request_duration_seconds Request time.\n# TYPE request_duration_seconds histogram\n", @metric.to_prom)
      end

      should "be registered with its buckets in a metric set" do
        set = Danbooru::Metric::Set.new([{ name: :queue_seconds, type: :histogram, buckets: [1, 2], help: "Queue time." }])

        assert_equal([1, 2], set[:queue_seconds].buckets)
      end
    end

    should "not allow observing a counter" do
      metric = Danbooru::Metric.new(:requests_total, type: :counter)

      assert_raises(ArgumentError) { metric.observe(1) }
    end
  end
end
