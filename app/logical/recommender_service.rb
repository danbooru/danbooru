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

    process_recs(body, uploader_id: user_id, favoriter_id: user_id)
  end

  def recommend_for_post(post_id, limit = 50)
    body, status = HttpartyCache.get("#{Danbooru.config.recommender_server}/similar/#{post_id}", params: { limit: limit }, expiry: CACHE_LIFETIME)
    return [] if status != 200

    process_recs(body, post_id: post_id)
  end

  def process_recs(recs, post_id: nil, uploader_id: nil, favoriter_id: nil)
    recs = JSON.parse(recs)

    posts = Post.where(id: recs.map(&:first))
    posts = posts.where.not(id: post_id) if post_id
    posts = posts.where.not(uploader_id: uploader_id) if uploader_id
    posts = posts.where.not(id: Favorite.where(user_id: favoriter_id).select(:post_id)) if favoriter_id

    id_to_score = recs.to_h
    recs = posts.map { |post| { score: id_to_score[post.id], post: post } }
    recs = recs.sort_by { |rec| -rec[:score] }
    recs
  end

  def search(params)
    if params[:user_id].present?
      user = User.find(params[:user_id])
      raise User::PrivilegeError if user.hide_favorites?
      max_recommendations = params.fetch(:max_recommendations, user.favorite_count + 500).to_i.clamp(0, 50000)
      recs = RecommenderService.recommend_for_user(params[:user_id], max_recommendations)
    elsif params[:post_id].present?
      max_recommendations = params.fetch(:max_recommendations, 50).to_i.clamp(0, 200)
      recs = RecommenderService.recommend_for_post(params[:post_id], max_recommendations)
    else
      recs = []
    end

    recs
  end
end
