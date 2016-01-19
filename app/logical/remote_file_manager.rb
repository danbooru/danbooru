require 'securerandom'

class RemoteFileManager
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def distribute
    uuid = SecureRandom.uuid
    temp_path = "/tmp/rfm-#{Danbooru.config.server_host}-#{uuid}"

    Danbooru.config.other_server_hosts.each do |hostname|
      Net::SFTP.start(hostname, Danbooru.config.remote_server_login) do |ftp|
        ftp.upload!(path, temp_path)
        begin
          ftp.rename!(temp_path, path)
        rescue Net::SFTP::StatusException
          # this typically means the file already exists
          # so just clean up
          ftp.remove(temp_path)
        end
      end
    end
  end

  def delete
    Danbooru.config.other_server_hosts.each do |hostname|
      Net::SFTP.start(hostname, Danbooru.config.remote_server_login) do |ftp|
        ftp.remove(path)
      end
    end
  end
end
