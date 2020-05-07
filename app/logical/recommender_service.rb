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

  def recommend_for_user(user, tags: nil, limit: 50)
    response = Danbooru::Http.cache(CACHE_LIFETIME).get("#{Danbooru.config.recommender_server}/recommend/#{user.id}", params: { limit: limit })
    return [] if response.status != 200

    process_recs(response.parse, tags: tags, uploader: user, favoriter: user)
  end

  def recommend_for_post(post, tags: nil, limit: 50)
    response = Danbooru::Http.cache(CACHE_LIFETIME).get("#{Danbooru.config.recommender_server}/similar/#{post.id}", params: { limit: limit })
    return [] if response.status != 200

    process_recs(response.parse, post: post, tags: tags)
  end

  def process_recs(recs, post: nil, uploader: nil, favoriter: nil, tags: nil)
    posts = Post.where(id: recs.map(&:first))
    posts = posts.where.not(id: post.id) if post
    posts = posts.where.not(uploader_id: uploader.id) if uploader
    posts = posts.where.not(id: favoriter.favorites.select(:post_id)) if favoriter
    posts = posts.where(id: Post.user_tag_match(tags).reorder(nil).select(:id)) if tags.present?

    id_to_score = recs.to_h
    recs = posts.map { |post| { score: id_to_score[post.id], post: post } }
    recs = recs.sort_by { |rec| -rec[:score] }
    recs
  end

  def search(params)
    if params[:user_name].present?
      user = User.find_by_name(params[:user_name])
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
    elsif params[:post_id].present?
      post = Post.find(params[:post_id])
    end

    if user.present?
      raise User::PrivilegeError unless Pundit.policy!([CurrentUser.user, nil], user).can_see_favorites?
      max_recommendations = params.fetch(:max_recommendations, user.favorite_count + 500).to_i.clamp(0, 50000)
      recs = RecommenderService.recommend_for_user(user, tags: params[:post_tags_match], limit: max_recommendations)
    elsif post.present?
      max_recommendations = params.fetch(:max_recommendations, 100).to_i.clamp(0, 1000)
      recs = RecommenderService.recommend_for_post(post, tags: params[:post_tags_match], limit: max_recommendations)
    else
      recs = []
    end

    recs
  end
end
