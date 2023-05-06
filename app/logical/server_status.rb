# frozen_string_literal: true

# Returns status information about the running server, including software
# versions, basic load info, and Redis and Postgres info.
#
# @see StatusController
# @see https://danbooru.donmai.us/status
class ServerStatus
  extend Memoist
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  attr_reader :request

  def initialize(request = nil)
    @request = request
  end

  def serializable_hash(options = {})
    {
      ip: request.remote_ip,
      headers: http_headers,
      instance: {
        container_name: container_name,
        instance_name: instance_name,
        worker_name: worker_name,
        container_uptime: container_uptime,
        instance_uptime: instance_uptime,
        worker_uptime: worker_uptime,
        requests_processed: requests_processed,
        danbooru_version: danbooru_version,
        ruby_version: ruby_version,
        rails_version: rails_version,
        puma_version: puma_version,
        distro_version: distro_version,
        libvips_version: libvips_version,
        ffmpeg_version: ffmpeg_version,
        mkvmerge_version: mkvmerge_version,
        exiftool_version: exiftool_version,
        redis_version: redis_version,
        postgres_version: postgres_version,
      },
      server: {
        node_name: node_name,
        node_uptime: node_uptime,
        loadavg: loadavg,
        kernel_version: kernel_version,
      },
      postgres: {
        connection_stats: postgres_connection_stats,
      },
      redis: {
        info: redis_info,
      },
    }
  end

  concerning :InfoMethods do
    def http_headers
      headers = request.headers.env.select { |key| key.starts_with?("HTTP_") }
      headers = headers.transform_keys { |key| key.delete_prefix("HTTP_").tr("_", "-").startcase }
      headers = headers.except("Cookie")
      headers = headers.transform_values { |v| v.encode("UTF-8", invalid: :replace, undef: :replace) }
      headers = headers.reject { |k, v| v.blank? }
      headers
    end

    def hostname
      Socket.gethostname
    end

    def instance_name
      if container_name.present?
        "#{container_name}/#{node_name}"
      else
        node_name
      end
    end

    def container_name
      ENV["K8S_POD_NAME"]
    end

    def node_name
      ENV["K8S_NODE_NAME"] || hostname
    end

    def worker_name
      Thread.current.object_id
    end

    def node_uptime
      uptime = File.read("/proc/uptime").split[0].to_f.seconds
      Danbooru::Helpers.distance_of_time_in_words(uptime)
    end

    def container_uptime
      started_at = File.stat("/proc/1").mtime
      uptime = Time.zone.now - started_at
      Danbooru::Helpers.distance_of_time_in_words(uptime)
    end

    def instance_uptime
      started_at = File.stat("/proc/#{Process.ppid}").mtime
      uptime = Time.zone.now - started_at
      Danbooru::Helpers.distance_of_time_in_words(uptime)
    end

    def worker_uptime
      started_at = File.stat("/proc/#{Process.pid}").mtime
      uptime = Time.zone.now - started_at
      Danbooru::Helpers.distance_of_time_in_words(uptime)
    end

    def requests_processed
      if Puma::Server.current.present?
        Puma::Server.current.requests_count
      end
    end

    def loadavg
      File.read("/proc/loadavg").chomp
    end

    def danbooru_version
      Rails.application.config.x.git_hash
    end

    def kernel_version
      File.read("/proc/version").chomp
    end

    def ruby_version
      RUBY_VERSION
    end

    def rails_version
      Rails.version
    end

    def puma_version
      Puma::Const::PUMA_VERSION
    end

    def distro_version
      `. /etc/os-release; echo "$NAME $VERSION"`.chomp
    end

    def libvips_version
      Vips::LIBRARY_VERSION
    end

    def ffmpeg_version
      version = `ffmpeg -version`
      version[/ffmpeg version ([0-9.]+)/, 1]
    end

    def mkvmerge_version
      `mkvmerge --version`.chomp
    end

    def exiftool_version
      `exiftool -ver`.chomp
    end
  end

  concerning :RedisMethods do
    def redis_info
      return {} if Rails.cache.try(:redis).nil?
      Rails.cache.redis.info
    rescue Redis::CannotConnectError
      {}
    end

    def redis_used_memory
      redis_info["used_memory_rss_human"]
    end

    def redis_version
      redis_info["redis_version"]
    end

    def redis_up?
      redis_version.present?
    end
  end

  concerning :PostgresMethods do
    def postgres_up?
      postgres_version.present?
    end

    def postgres_version
      ApplicationRecord.connection.select_value("SELECT version()")
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    def postgres_active_connections
      ApplicationRecord.connection.select_value("SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active'")
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    def postgres_connection_stats
      run_query("SELECT pid, state, query_start, state_change, xact_start, backend_start, backend_type FROM pg_stat_activity ORDER BY state, query_start DESC, backend_type")
    end

    def run_query(query)
      result = ApplicationRecord.connection.select_all(query)
      serialize_result(result)
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    def serialize_result(result)
      result.rows.map do |row|
        row.each_with_index.map do |col, i|
          [result.columns[i], col]
        end.to_h
      end
    end
  end

  memoize :redis_info, :kernel_version, :distro_version, :ffmpeg_version
end
