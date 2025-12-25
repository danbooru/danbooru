# A StorageManager that stores files on a remote filesystem using SFTP.
class StorageManager::SFTP < StorageManager
  DEFAULT_PERMISSIONS = 0o644
  DEFAULT_DIRECTORY_PERMISSIONS = 0o755

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

  attr_reader :host, :pool, :base_dir, :max_requests, :buffer_size, :ssh_options

  # @param host [String] The hostname of the remote server.
  # @param base_dir [String] The directory to store files in.
  # @param max_connections [Integer] The maximum number of persistent SFTP connections to allow.
  # @param max_requests [Integer] The maximum number of simultaneous read/write operations during uploads and downloads. More requests means higher throughput.
  # @param buffer_size [Integer] The buffer size for read/write operations during uploads and downloads. Bigger buffers means higher throughput. 262,120 is the maximum packet size supported by OpenSSH.
  # @param pool_timeout [Integer] The maximum number of seconds to wait for a SFTP connection to become available.
  # @param ssh_options [Hash] Additional options to pass to Net::SSH.
  # @param options [Hash] Additional options to pass to StorageManager.
  def initialize(host, base_dir: "/", max_connections: Danbooru.config.max_concurrency, max_requests: 8, buffer_size: 256_000, pool_timeout: 15, ssh_options: {}, **options)
    @host = host
    @base_dir = base_dir.to_s
    @max_requests = max_requests
    @buffer_size = buffer_size
    @ssh_options = DEFAULT_SSH_OPTIONS.merge(ssh_options)
    @pool = ConnectionPool.new(size: max_connections, timeout: pool_timeout) do
      SFTPConnection.open(host, **@ssh_options)
    end

    super(**options)
  end

  def store(file, dest_path)
    dest_path = full_path(dest_path)
    temp_upload_path = dest_path + "-" + SecureRandom.uuid + ".tmp"
    dest_backup_path = dest_path + "-" + SecureRandom.uuid + ".bak"

    with_connection do |sftp|
      sftp.mkdir_p!(File.dirname(dest_path))

      sftp.upload!(file.path, temp_upload_path, read_size: buffer_size, requests: max_requests)
      sftp.setstat!(temp_upload_path, permissions: DEFAULT_PERMISSIONS)

      # `rename!` can't overwrite existing files, so if a file already exists at dest_path we move it out of the way first.
      sftp.mv_f!(dest_path, dest_backup_path)
      sftp.mv_f!(temp_upload_path, dest_path)
    rescue StandardError
      # if anything fails, try to move the original file back in place (if it was moved).
      sftp.mv_f!(dest_backup_path, dest_path)
      raise
    ensure
      sftp.rm_f!(temp_upload_path)
      sftp.rm_f!(dest_backup_path)
    end
  end

  def delete(dest_path)
    with_connection do |sftp|
      sftp.rm_f!(full_path(dest_path))
    end
  end

  def open(dest_path)
    file = Tempfile.new(binmode: true)

    with_connection do |sftp|
      sftp.download!(full_path(dest_path), file.path, read_size: buffer_size, requests: max_requests)
    end

    file
  end

  def with_connection(&block)
    pool.then do |sftp|
      sftp.connect!
      yield sftp
    end
  rescue Exception
    # If we get an exception, reload the whole connection pool in case one of the connections is in a bad state.
    close_pool!
    raise
  end

  def close_pool! # Pool's closed
    pool.reload { |sftp| sftp.session.close }
  end

  def full_path(path)
    File.join(base_dir, path)
  end

  # A wrapper around a `Net::SFTP` connection that adds a few extra utility methods.
  class SFTPConnection
    attr_reader :sftp

    delegate :upload!, :download!, :setstat!, :rename!, :remove!, :stat!, :session, to: :sftp
    delegate_missing_to :sftp

    def self.open(host, **ssh_options)
      SFTPConnection.new(Net::SFTP.start(host, nil, ssh_options))
    end

    # @param sftp [Net::SFTP::Session] The SFTP connection.
    def initialize(sftp)
      @sftp = sftp
    end

    # Remove a file, ignoring any errors if it doesn't exist.
    def rm_f!(path)
      force { sftp.remove!(path) }
    end

    # Move a file, ignoring any errors if the source file doesn't exist.
    def mv_f!(src, dest)
      force { sftp.rename!(src, dest) }
    end

    # Create a directory and its parent directories, ignoring any errors if it already exists.
    def mkdir_p!(path, permissions: DEFAULT_DIRECTORY_PERMISSIONS)
      return if directory?(path)

      dirs = path.split("/").compact_blank
      parent_dir = ""

      dirs.each do |dir|
        parent_dir = "#{parent_dir}/#{dir}"
        mkdir_f!(parent_dir, permissions: permissions)
      end
    end

    # Create a directory, ignoring any errors if it already exists.
    def mkdir_f!(path, permissions: DEFAULT_DIRECTORY_PERMISSIONS)
      sftp.mkdir!(path, permissions: permissions)
    rescue Net::SFTP::StatusException
      raise unless directory?(path)
    end

    # Return true if path is a directory.
    def directory?(path)
      sftp.stat!(path).directory?
    rescue Net::SFTP::StatusException => e
      raise unless e.description == "no such file"
      false
    end

    # Ignore "no such file" exceptions for the given operation.
    def force
      yield
    rescue Net::SFTP::StatusException => e
      raise unless e.description == "no such file"
    end
  end
end
