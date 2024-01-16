# frozen_string_literal: true

# This starts a background thread that serves process metrics at http://0.0.0.0:9090/metrics. It's used by GoodJob
# workers (`bin/good_job start`) and by the cron process (`bin/rails danbooru:cron`) to expose internal metrics.
#
# @see config/initializers/good_job.rb
# @see lib/tasks/danbooru.rake
class RackMetricsServer
  attr_reader :host, :port, :options, :server, :thread

  def initialize(host: ENV.fetch("DANBOORU_METRICS_HOST", "0.0.0.0"), port: ENV.fetch("DANBOORU_METRICS_PORT", 3000), **options)
    @host = host
    @port = port
    @options = options
  end

  def start
    @server = Rackup::Handler.get("webrick")
    @thread = Thread.new do
      logger = DanbooruLogger.new(default_level: Logger::DEBUG)
      @server.run(self, Host: host, Port: port, AccessLog: [[logger, WEBrick::AccessLog::COMBINED_LOG_FORMAT]], **options)
    end

    self
  end

  def call(env)
    request = Rack::Request.new(env)

    case request.path_info
    when "/health", "/healthz", "/up"
      [200, {}, []]
    when "/metrics", "/metrics/instance"
      metrics = ApplicationMetrics.update_process_metrics.to_prom
      [200, {"Content-Type" => "text/plain"}, [metrics]]
    else
      [404, {}, []]
    end
  end
end
