# A StorageManager that stores files on a remote filesystem using SFTP.
class StorageManager::SFTP < StorageManager
  DEFAULT_PERMISSIONS = 0o644

  # http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start
  DEFAULT_SSH_OPTIONS = {
    timeout: 10,
    keepalive: true,
    keepalive_interval: 5,
    keepalive_maxcount: 3,
    logger: Rails.logger,
    verbose: Danbooru.config.log_level.to_s == "info" ? :warn : Danbooru.config.log_level, # the :info log level is too verbose
    non_interactive: true
  }

  attr_reader :host, :pool, :base_dir, :ssh_options

  # @param host [String] The hostname of the remote server.
  # @param base_dir [String] The directory to store files in.
  # @param max_connections [Integer] The maximum number of persistent SFTP connections to allow.
  # @param pool_timeout [Integer] The maximum number of seconds to wait for a SFTP connection to become available.
  # @param ssh_options [Hash] Additional options to pass to Net::SSH.
  # @param options [Hash] Additional options to pass to StorageManager.
  def initialize(host, base_dir: "/", max_connections: Danbooru.config.max_concurrency, pool_timeout: 15, ssh_options: {}, **options)
    @host = host
    @base_dir = base_dir.to_s
    @ssh_options = DEFAULT_SSH_OPTIONS.merge(ssh_options)
    @pool = ConnectionPool.new(size: max_connections, timeout: pool_timeout) do
      Net::SFTP.start(host, nil, @ssh_options)
    end

    super(**options)
  end

  def store(file, dest_path)
    dest_path = full_path(dest_path)
    temp_upload_path = dest_path + "-" + SecureRandom.uuid + ".tmp"
    dest_backup_path = dest_path + "-" + SecureRandom.uuid + ".bak"

    with_connection do |sftp|
      sftp.upload!(file.path, temp_upload_path)
      sftp.setstat!(temp_upload_path, permissions: DEFAULT_PERMISSIONS)

      # `rename!` can't overwrite existing files, so if a file already exists
      # at dest_path we move it out of the way first.
      force { sftp.rename!(dest_path, dest_backup_path) }
      force { sftp.rename!(temp_upload_path, dest_path) }
    rescue StandardError => e
      # if anything fails, try to move the original file back in place (if it was moved).
      force { sftp.rename!(dest_backup_path, dest_path) }
      raise Error, e
    ensure
      force { sftp.remove!(temp_upload_path) }
      force { sftp.remove!(dest_backup_path) }
    end
  end

  def delete(dest_path)
    with_connection do |sftp|
      force { sftp.remove!(full_path(dest_path)) }
    end
  end

  def open(dest_path)
    file = Tempfile.new(binmode: true)

    with_connection do |sftp|
      sftp.download!(full_path(dest_path), file.path)
    end

    file
  end

  protected

  def with_connection(&block)
    pool.then do |sftp|
      sftp.connect!
      yield sftp
    end
  rescue Exception
    # If we get an exception, reload the whole connection pool just in case one of the connections is in a bad state.
    pool.reload { |sftp| sftp.session.close }
    raise
  end

  # Ignore "no such file" exceptions for the given operation.
  def force
    yield
  rescue Net::SFTP::StatusException => e
    raise Error, e unless e.description == "no such file"
  end

  def full_path(path)
    File.join(base_dir, path)
  end
end
