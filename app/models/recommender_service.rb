module RecommenderService
  extend self

  SCORE_THRESHOLD = 10

  def enabled?
    Danbooru.config.recommender_server.present?
  end

  def available?(post)
    enabled? && CurrentUser.enable_recommended_posts? && post.created_at > Date.civil(2018, 1, 1) #&& post.score >= SCORE_THRESHOLD
  end

  def similar(post)
    if Danbooru.config.recommender_server == "development"
      return Post.order("random()").limit(6).map {|x| [x.id, "1.000"]}
    end

    Cache.get("rss:#{post.id}", 1.day) do
      resp = HTTParty.get(
        "#{Danbooru.config.recommender_server}/similar/#{post.id}", 
        Danbooru.config.httparty_options.merge(
          basic_auth: {
            username: "danbooru", 
            password: Danbooru.config.recommender_key
          }
        )
      )
      JSON.parse(resp.body)
    end
  end
end
