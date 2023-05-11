# frozen_string_literal: true

# Adds the Server-Timing and X-Runtime HTTP response headers.
class RackServerTiming
  def initialize(app)
    @app = app
    @metrics = Hash.new(0)
    @subscribers = initialize_subscribers
  end

  def call(env)
    total_time_before = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond)
    cpu_time_before = Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID, :float_millisecond)
    gc_count_before = GC.count
    gc_time_before = GC.total_time / 1_000_000.0
    allocations_before = GC.stat(:total_allocated_objects)

    @metrics.clear
    _, headers, _ = response = @app.call(env)

    @metrics[:"request.allocations"] = GC.stat(:total_allocated_objects) - allocations_before
    @metrics[:"request.gc_time"] = (GC.total_time / 1_000_000.0) - gc_time_before
    @metrics[:"request.gc_count"] = GC.count - gc_count_before
    @metrics[:"request.cpu_time"] = Process.clock_gettime(Process::CLOCK_THREAD_CPUTIME_ID, :float_millisecond) - cpu_time_before
    @metrics[:"request.total_time"] = Process.clock_gettime(Process::CLOCK_MONOTONIC, :float_millisecond) - total_time_before

    headers["Server-Timing"] = build_header
    headers["X-Runtime"] = @metrics[:"request.total_time"] / 1000.0

    response
  end

  def build_header
    @metrics.map do |key, value|
      if value.is_a?(Float)
        "#{key};dur=#{value.round(4)}"
      else
        "#{key};count=#{value}"
      end
    end.join(", ")
  end

  def initialize_subscribers
    subscribers = []

    subscribers << ActiveSupport::Notifications.monotonic_subscribe("process_action.action_controller") do |event|
      payload = event.payload

      @metrics[:"rails.total_time"] += event.duration
      @metrics[:"rails.cpu_time"] += event.cpu_time
      @metrics[:"rails.idle_time"] += event.idle_time
      @metrics[:"rails.sql_time"] += payload[:db_runtime].to_f
      @metrics[:"rails.view_time"] += payload[:view_runtime].to_f
      @metrics[:"rails.allocations"] += event.allocations
    end

    subscribers << ActiveSupport::Notifications.monotonic_subscribe("sql.active_record") do |event|
      next if event.payload[:cached]
      @metrics[:"sql.queries"] += 1
    end

    subscribers << ActiveSupport::Notifications.monotonic_subscribe(/\Acache_(read|read_multi|write|write_multi)\.active_support/) do |event|
      payload = event.payload

      case event.name
      when "cache_read.active_support"
        @metrics[:"cache.reads"] += 1
        @metrics[:"cache.keys_read"] += 1
        @metrics[:"cache.keys_hit"] += 1 if payload[:hit]
      when "cache_write.active_support"
        @metrics[:"cache.writes"] += 1
        @metrics[:"cache.keys_written"] += 1
      when "cache_read_multi.active_support"
        key = payload[:key]
        next if key.empty?

        @metrics[:"cache.reads"] += 1
        @metrics[:"cache.keys_read"] += key.size
        @metrics[:"cache.keys_hit"] += payload[:hits].size
      when "cache_write_multi.active_support"
        key = payload[:key]
        next if key.empty?

        @metrics[:"cache.writes"] += 1
        @metrics[:"cache.keys_written"] += key.size
      end

      @metrics[:"cache.total_time"] += event.duration
    end

    subscribers
  end
end
