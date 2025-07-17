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
        environment: environment,
        rails_environment: Rails.env,
        container_name: container_name,
        worker_name: worker_name,
        container_uptime: container_uptime,
        instance_uptime: instance_uptime,
        worker_uptime: worker_uptime,
        requests_processed: requests_processed,
      },
      version: {
        docker_image_build_date: docker_image_build_date,
        danbooru_version: danbooru_version,
        ruby_version: ruby_version,
        rails_version: rails_version,
        puma_version: puma_version,
        distro_version: distro_version,
        libvips_version: libvips_version,
        ffmpeg_version: ffmpeg_version,
        mkvmerge_version: mkvmerge_version,
        exiftool_version: exiftool_version,
        jemalloc_version: jemalloc_version,
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
        up: postgres_up?,
        error: postgres_error,
        connection_stats: postgres_connection_stats,
      },
      redis: {
        up: redis_up?,
        info: redis_info,
      }
    }
  end

  concerning :InfoMethods do
    extend Memoist

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

    def kubernetes?
      ENV["KUBERNETES_SERVICE_HOST"].present?
    end

    def docker?
      ENV["DOCKER"] == "true" || File.exist?("/.dockerenv")
    end

    def environment
      if kubernetes?
        "kubernetes"
      elsif docker?
        "docker"
      else
        "bare-metal"
      end
    end

    memoize def container_name
      if kubernetes?
        ENV["K8S_POD_NAME"]
      elsif docker?
        # Do a reverse DNS lookup on the container IP address to get the container name.
        docker_ip = Socket.ip_address_list.find(&:ipv4_private?)&.ip_address
        Resolv::DNS.new.getname(docker_ip).to_a[0..-2].map(&:to_s).join(".")
      end
    rescue Resolv::ResolvError
      nil
    end

    def node_name
      if kubernetes?
        ENV["K8S_NODE_NAME"]
      elsif docker?
        nil
      else
        hostname
      end
    end

    def worker_name
      "PID:#{Process.pid} TID:#{Thread.current.object_id}"
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

    def docker_image_build_date
      Time.zone.parse(ENV["DOCKER_IMAGE_BUILD_DATE"]) if ENV["DOCKER_IMAGE_BUILD_DATE"].present?
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
    rescue
      nil
    end

    def ffmpeg_installed?
      ffmpeg_version.present?
    end

    def mkvmerge_version
      `mkvmerge --version`.chomp
    rescue
      nil
    end

    def mkvmerge_installed?
      mkvmerge_version.present?
    end

    def exiftool_version
      `exiftool -ver`.chomp
    rescue
      nil
    end

    def exiftool_installed?
      exiftool_version.present?
    end

    def jemalloc_version
      Jemalloc.version
    end

    def jemalloc_installed?
      jemalloc_version.present?
    end

    def instance_error
      if !exiftool_installed?
        "ExifTool not installed"
      elsif !ffmpeg_installed?
        "FFmpeg not installed"
      elsif !mkvmerge_installed?
        "Mkvmerge not installed"
      else
        nil
      end
    end
  end

  concerning :RedisMethods do
    def redis_info
      return {} if Rails.cache.try(:redis).nil?
      Rails.cache.redis.with(&:info)
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
      postgres_error.nil?
    end

    def postgres_error
      ApplicationRecord.connection.select_value("SELECT version()")
      nil
    rescue ActiveRecord::ActiveRecordError => error
      error.message
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
      result = ApplicationRecord.connection.select_all("SELECT now() - xact_start AS transaction_duration, now() - query_start AS query_duration, application_name AS source, wait_event FROM pg_stat_activity WHERE state = 'active' ORDER BY 2 DESC, pid")
      serialize_result(result)
    rescue ActiveRecord::ActiveRecordError
      nil
    end

    def serialize_result(result)
      result.rows.map do |row|
        row.each_with_index.map do |column_value, i|
          column_name = result.columns[i]

          if result.column_types[column_name]&.type == :interval
            column_value = Danbooru::Helpers.duration_to_hhmmssms(ActiveSupport::Duration.parse(column_value).to_f.clamp(0.0..))
          end

          [column_name, column_value]
        end.to_h
      end
    end
  end

  memoize :redis_info, :kernel_version, :distro_version, :ffmpeg_version
end
