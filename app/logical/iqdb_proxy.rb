class IqdbProxy
  def self.query(image_url)
    raise NotImplementedError unless Danbooru.config.iqdbs_server.present?

    url = URI.parse(Danbooru.config.iqdbs_server)
    url.path = "/similar"
    url.query = {url: image_url}.to_query
    json = HTTParty.get(url.to_s, Danbooru.config.httparty_options).parsed_response
    decorate_posts(json)
  end

  def self.decorate_posts(json)
    json.map do |x|
      begin
        x["post"] = Post.find(x["post_id"])
        x
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end.compact
  end
end
