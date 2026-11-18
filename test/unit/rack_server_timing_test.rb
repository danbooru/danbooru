require "test_helper"

class RackServerTimingTest < ActiveSupport::TestCase
  def prom
    ApplicationMetrics[:rails_http_request_queue_duration_seconds].to_prom
  end

  def request(headers = {})
    Rack::MockRequest.new(@middleware).get("/", headers)
  end

  context "RackServerTiming" do
    setup do
      ApplicationMetrics.reset_metrics
      @middleware = RackServerTiming.new(->(_env) { [200, {}, ["ok"]] })
      @now = 1_700_000_000.0
      Process.stubs(:clock_gettime).returns(0.0)
      Process.stubs(:clock_gettime).with(Process::CLOCK_REALTIME).returns(@now)
    end

    teardown do
      ApplicationMetrics.reset_metrics
    end

    should "record the time since nginx received the request" do
      response = request("HTTP_X_REQUEST_START" => "#{@now - 0.5}, #{@now - 0.02}")

      assert_match(/request\.queue_time_0;dur=20\.0/, response.headers["Server-Timing"])
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.01"} 0})
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.025"} 1})
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.05"} 1})
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_bucket{le="+Inf"} 1})
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_count 1})
      assert_in_delta(0.02, prom[/^rails_http_request_queue_duration_seconds_sum (\S+)$/, 1].to_f, 0.0001)
    end

    should "record a negative queue time from clock differences as zero" do
      request("HTTP_X_REQUEST_START" => (@now + 0.003).to_s)

      assert_includes(prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.001"} 1})
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_sum 0})
    end

    should "record the queue time for requests that raise an exception" do
      @middleware = RackServerTiming.new(->(_env) { raise Rack::Timeout::RequestTimeoutException, {} })

      assert_raises(Rack::Timeout::RequestTimeoutException) do
        request("HTTP_X_REQUEST_START" => (@now - 0.02).to_s)
      end

      assert_includes(prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.025"} 1})
      assert_includes(prom, %{rails_http_request_queue_duration_seconds_count 1})
    end

    should "not record anything if nginx's start time is missing or invalid" do
      request
      request("HTTP_X_REQUEST_START" => "garbage")
      request("HTTP_X_REQUEST_START" => "#{@now - 0.5}, garbage")

      assert_no_match(/^rails_http_request_queue_duration_seconds_/, prom)
    end
  end
end
