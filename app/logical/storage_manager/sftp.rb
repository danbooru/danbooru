class StorageManager::SFTP < StorageManager
  DEFAULT_PERMISSIONS = 0o644

  # http://net-ssh.github.io/net-ssh/Net/SSH.html#method-c-start
  DEFAULT_SSH_OPTIONS = {
    timeout: 10,
    logger: Rails.logger,
    verbose: :fatal,
    non_interactive: true
  }

  attr_reader :hosts, :ssh_options

  def initialize(*hosts, ssh_options: {}, **options)
    @hosts = hosts
    @ssh_options = DEFAULT_SSH_OPTIONS.merge(ssh_options)
    super(**options)
  end

  def store(file, dest_path)
    temp_upload_path = dest_path + "-" + SecureRandom.uuid + ".tmp"
    dest_backup_path = dest_path + "-" + SecureRandom.uuid + ".bak"

    each_host do |_host, sftp|
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
    each_host do |_host, sftp|
      force { sftp.remove!(dest_path) }
    end
  end

  def open(dest_path)
    file = Tempfile.new(binmode: true)

    Net::SFTP.start(hosts.first, nil, ssh_options) do |sftp|
      sftp.download!(dest_path, file.path)
    end

    file
  end

  protected

  # Ignore "no such file" exceptions for the given operation.
  def force
    yield
  rescue Net::SFTP::StatusException => e
    raise Error, e unless e.description == "no such file"
  end

  def each_host
    hosts.each do |host|
      Net::SFTP.start(host, nil, ssh_options) do |sftp|
        yield host, sftp
      end
    end
  end
end
