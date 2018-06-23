class IqdbProxy
  def self.query(url)
    raise NotImplementedError unless Danbooru.config.iqdbs_server.present?

    url = URI.parse(Danbooru.config.iqdbs_server)
    url.path = "/similar"
    url.query = {url: url}.to_query
    json = HTTParty.get(url.to_s, Danbooru.config.httparty_options).parsed_response
    decorate_posts(json)
  end

  def self.decorate_posts(json)
    json.map do |x|
      x["post"] = Post.find(x["id"])
      x
    end
  end
end
