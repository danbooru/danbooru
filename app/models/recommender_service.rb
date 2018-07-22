module RecommenderService
  extend self

  SCORE_THRESHOLD = 5

  def enabled?
    Danbooru.config.recommender_server.present?
  end

  def available_for_post?(post)
    return true if Rails.env.development?

    enabled? && post.created_at > Date.civil(2017, 1, 1) && post.fav_count >= SCORE_THRESHOLD
  end

  def available_for_user?
    enabled? && CurrentUser.is_gold?
  end

  def recommend_for_user(user_id)
    ids = Cache.get("rsu:#{user_id}", 1.hour) do
      resp = HTTParty.get(
        "#{Danbooru.config.recommender_server}/recommend/#{user_id}", 
        Danbooru.config.httparty_options.merge(
          basic_auth: {
            username: "danbooru", 
            password: Danbooru.config.recommender_key
          }
        )
      )
      JSON.parse(resp.body)
    end
    Post.find(ids.map(&:first))
  end

  def recommend_for_post(post_id)
    ids = Cache.get("rss:#{post_id}", 1.hour) do
      resp = HTTParty.get(
        "#{Danbooru.config.recommender_server}/similar/#{post_id}", 
        Danbooru.config.httparty_options.merge(
          basic_auth: {
            username: "danbooru", 
            password: Danbooru.config.recommender_key
          }
        )
      )
      JSON.parse(resp.body)
    end
    Post.find(ids.reject {|x| x[0] == post_id}.map(&:first))
  end

  def recommend(post_id: nil, user_id: nil)
    if post_id
      recommend_for_post(post_id)
    elsif user_id
      recommend_for_user(user_id)
    end
  end
end
