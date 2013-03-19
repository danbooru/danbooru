class RemoteFileManager
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def distribute
    Danbooru.config.other_server_hosts.each do |hostname|
      Net::SFTP.start(hostname, Danbooru.config.remote_server_login) do |ftp|
        ftp.upload!(path, path)
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
