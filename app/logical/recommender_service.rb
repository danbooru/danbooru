module RecommenderService
  module_function

  MIN_POST_FAVS = 5
  MIN_USER_FAVS = 50
  CACHE_LIFETIME = 4.hours

  def enabled?
    Danbooru.config.recommender_server.present?
  end

  def available_for_post?(post)
    enabled? && post.fav_count > MIN_POST_FAVS
  end

  def available_for_user?(user)
    enabled? && user.favorite_count > MIN_USER_FAVS
  end

  def recommend_for_user(user_id, limit = 50)
    body, status = HttpartyCache.get("#{Danbooru.config.recommender_server}/recommend/#{user_id}", params: { limit: limit }, expiry: CACHE_LIFETIME)
    return [] if status != 200

    process_recs(body)
  end

  def recommend_for_post(post_id, limit = 50)
    body, status = HttpartyCache.get("#{Danbooru.config.recommender_server}/similar/#{post_id}", params: { limit: limit }, expiry: CACHE_LIFETIME)
    return [] if status != 200

    process_recs(body).reject { |rec| rec[:post].id == post_id }
  end

  def process_recs(recs)
    recs = JSON.parse(recs).to_h
    recs = Post.where(id: recs.keys).map { |post| { score: recs[post.id], post: post } }
    recs = recs.sort_by { |rec| -rec[:score] }
    recs
  end
end
