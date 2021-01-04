class ServerStatus
  extend Memoist
  include ActiveModel::Serializers::JSON
  include ActiveModel::Serializers::Xml

  def serializable_hash(*options)
    {
      status: {
        hostname: hostname,
        uptime: uptime,
        loadavg: loadavg,
        ruby_version: RUBY_VERSION,
        distro_version: distro_version,
        kernel_version: kernel_version,
        libvips_version: libvips_version,
        ffmpeg_version: ffmpeg_version,
        mkvmerge_version: mkvmerge_version,
        redis_version: redis_version,
        postgres_version: postgres_version,
      },
      postgres: {
        connection_stats: postgres_connection_stats,
      },
      redis: {
        info: redis_info,
      }
    }
  end

  concerning :InfoMethods do
    def hostname
      Socket.gethostname
    end

    def uptime
      seconds = File.read("/proc/uptime").split[0].to_f
      "#{seconds.seconds.in_days.round} days"
    end

    def loadavg
      File.read("/proc/loadavg").chomp
    end

    def kernel_version
      File.read("/proc/version").chomp
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
  end

  concerning :RedisMethods do
    def redis_info
      return {} if Rails.cache.try(:redis).nil?
      Rails.cache.redis.info
    end

    def redis_used_memory
      redis_info["used_memory_rss_human"]
    end

    def redis_version
      redis_info["redis_version"]
    end
  end

  concerning :PostgresMethods do
    def postgres_version
      ApplicationRecord.connection.select_value("SELECT version()")
    end

    def postgres_active_connections
      ApplicationRecord.connection.select_value("SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active'")
    end

    def postgres_connection_stats
      run_query("SELECT pid, state, query_start, state_change, xact_start, backend_start, backend_type FROM pg_stat_activity ORDER BY state, query_start DESC, backend_type")
    end

    def run_query(query)
      result = ApplicationRecord.connection.select_all(query)
      serialize_result(result)
    end

    def serialize_result(result)
      result.rows.map do |row|
        row.each_with_index.map do |col, i|
          [result.columns[i], col]
        end.to_h
      end
    end
  end

  memoize :redis_info
end
