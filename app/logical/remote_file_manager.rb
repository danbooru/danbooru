require 'securerandom'

class RemoteFileManager
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def distribute_to_archive(dest_url)
    uri = URI.parse(dest_url)
    dir_name = uri.host.split(".").first
    uuid = SecureRandom.uuid
    dest_path = "/var/www/#{dir_name}#{uri.path}"
    temp_path = "/tmp/rfm-#{Danbooru.config.server_host}-#{uuid}"
    
    Net::SFTP.start(uri.host, Danbooru.config.archive_server_login) do |ftp|
      ftp.upload!(path, temp_path)
      begin
        ftp.rename!(temp_path, dest_path)
      rescue Net::SFTP::StatusException
        ftp.remove!(dest_path)
        ftp.rename!(temp_apth, dest_path)
      end
    end
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
          # so delete and try renaming again
          ftp.remove!(path)
          ftp.rename!(temp_path, path)
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
