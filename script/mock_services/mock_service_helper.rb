require 'socket'
require 'timeout'
require 'httparty'

module MockServiceHelper
  module_function

  DANBOORU_PORT = 3000

  def fetch_post_ids
    begin
      s = TCPSocket.new("localhost", DANBOORU_PORT)
      s.close
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
      sleep 1
      retry
    end

    json = HTTParty.get("http://localhost:#{DANBOORU_PORT}/posts.json?random=true&limit=10").body
    return JSON.parse(json).map {|x| x["id"]}
  end
end
