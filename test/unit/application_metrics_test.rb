require "test_helper"

class ApplicationMetricsTest < ActiveSupport::TestCase
  # The value of the instance-wide counter with the given labels, as reported by the master.
  def total(name, labels = @labels)
    @master.instance_process_metrics[name].values.find { |value| value.labels == labels }&.value
  end

  context "ApplicationMetrics" do
    setup do
      @master = ApplicationMetrics.new.tap { |m| m.puma_worker_id = "master" }
      @worker = ApplicationMetrics.new.tap { |m| m.puma_worker_id = "3" }
      Puma.stubs(:stats_hash).returns({ started_at: Time.now.utc.iso8601, workers: 1, worker_status: [] })
      Process.stubs(:ppid).returns(Process.pid) # The worker is a child of the master
      @labels = { method: "GET", controller: "posts", action: "index", format: "text/html", status: "200" }

      DRbObject.stubs(:new_with_uri).with("drbunix:tmp/drb-process-metrics-#{Process.pid}-master.sock").returns(@master)
      DRbObject.stubs(:new_with_uri).with("drbunix:tmp/drb-process-metrics-#{Process.pid}-3.sock").returns(@worker)
      Dir.stubs(:glob).with("tmp/drb-process-metrics-#{Process.pid}-*.sock").returns(["tmp/drb-process-metrics-#{Process.pid}-3.sock", "tmp/drb-process-metrics-#{Process.pid}-master.sock"])
    end

    context "#poll_worker_counters" do
      should "add up the increase in each worker's counters without counting anything twice" do
        @worker[:rails_http_requests_total][@labels].increment(5)
        @worker[:rails_http_request_duration_seconds][**@labels, duration: "cpu"].increment(1.5)
        @master.poll_worker_counters
        @master.poll_worker_counters

        assert_equal(5, total(:rails_http_requests_total))
        assert_equal(1.5, total(:rails_http_request_duration_seconds, { **@labels, duration: "cpu" }))

        @worker[:rails_http_requests_total][@labels].increment(3)
        @master.poll_worker_counters

        assert_equal(8, total(:rails_http_requests_total))
      end

      should "keep the counts from a worker that was replaced by a new process" do
        @master.absorb_counter_snapshot(100, { rails_http_requests_total: { @labels => 10 }})
        @master.absorb_counter_snapshot(200, { rails_http_requests_total: { @labels => 2 }})

        assert_equal(12, total(:rails_http_requests_total))
      end

      should "never decrease the totals if a PID is reused by a new worker" do
        @master.absorb_counter_snapshot(100, { rails_http_requests_total: { @labels => 10 }})
        @master.absorb_counter_snapshot(100, { rails_http_requests_total: { @labels => 3 }})

        assert_equal(10, total(:rails_http_requests_total))
      end

      should "skip workers that can't be reached" do
        DRbObject.stubs(:new_with_uri).with("drbunix:tmp/drb-process-metrics-#{Process.pid}-3.sock").raises(DRb::DRbConnError)

        assert_nothing_raised { @master.poll_worker_counters }
      end
    end

    context "#retire_worker_metrics" do
      should "send the worker's final counts to the master" do
        @worker[:rails_http_requests_total][@labels].increment(5)
        @master.poll_worker_counters
        @worker[:rails_http_requests_total][@labels].increment(2)
        @worker.retire_worker_metrics

        assert_equal(7, total(:rails_http_requests_total))
      end

      should "not raise if the master is unreachable" do
        DRbObject.stubs(:new_with_uri).with("drbunix:tmp/drb-process-metrics-#{Process.pid}-master.sock").raises(DRb::DRbConnError)

        assert_nothing_raised { @worker.retire_worker_metrics }
      end
    end

    context "#instance_process_metrics" do
      should "report the summed counters from the master and only the other metrics from the workers" do
        @worker[:rails_http_requests_total][@labels].increment(5)
        @worker[:ruby_gc_total][{}].increment(100)
        @master.poll_worker_counters

        master_prom = @master.instance_process_metrics.to_prom
        worker_prom = @worker.instance_process_metrics.to_prom

        assert_includes(master_prom, %{rails_http_requests_total{method="GET", controller="posts", action="index", format="text/html", status="200"} 5})
        assert_no_match(/^rails_http_requests_total/, worker_prom)
        assert_match(/^ruby_gc_total\{worker="3"\} 100$/, worker_prom)
        assert_no_match(/^ruby_gc_total.* 100$/, master_prom)
      end

      should "report the summed histograms from the master" do
        @worker[:rails_http_request_queue_duration_seconds].observe(0.003)
        @master.poll_worker_counters
        @worker[:rails_http_request_queue_duration_seconds].observe(0.2)
        @master.poll_worker_counters

        master_prom = @master.instance_process_metrics.to_prom
        worker_prom = @worker.instance_process_metrics.to_prom

        assert_includes(master_prom, "# TYPE rails_http_request_queue_duration_seconds histogram")
        assert_includes(master_prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.001"} 0})
        assert_includes(master_prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.005"} 1})
        assert_includes(master_prom, %{rails_http_request_queue_duration_seconds_bucket{le="0.25"} 2})
        assert_includes(master_prom, %{rails_http_request_queue_duration_seconds_bucket{le="+Inf"} 2})
        assert_includes(master_prom, %{rails_http_request_queue_duration_seconds_sum 0.203})
        assert_includes(master_prom, %{rails_http_request_queue_duration_seconds_count 2})
        assert_no_match(/^rails_http_request_queue_duration_seconds/, worker_prom)
      end
    end
  end
end
