class RemoteServer
  attr_accessor :hostname
  
  def self.other_servers
    Danbooru.config.other_server_hosts.map {|x| new(x)}
  end
  
  def self.copy_to_all(local_path, remote_path)
    other_servers.each do |server|
      server.copy(local_path, remote_path)
    end
  end
  
  def self.delete_from_all(remote_path)
    other_servers.each do |server|
      server.delete(remote_path)
    end
  end
  
  def initialize(hostname)
    @hostname = hostname
  end
  
  def copy(local_path, remote_path)
    Net::SFTP.start(hostname, Danbooru.config.remote_server_login) do |ftp|
      ftp.upload!(local_path, remote_path)
    end
  end
  
  def delete(remote_path)
    Net::SFTP.start(hostname, Danbooru.config.remote_server_login) do |ftp|
      ftp.remove(remote_path)
    end
  end
end
