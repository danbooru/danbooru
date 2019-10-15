class IqdbProxy
  def self.query(url, limit, similarity)
    raise NotImplementedError unless Danbooru.config.iqdbs_server.present?

    limit ||= 20
    similarity ||= 0.0
    query = { url: url, limit: limit }
    response = HTTParty.get("#{Danbooru.config.iqdbs_server}/similar", query: query, **Danbooru.config.httparty_options)

    json = decorate_posts(response.parsed_response)
    json = json.select { |result| result["score"] >= similarity.to_f }.take(limit.to_i)
    json
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
