# frozen_string_literal: true

# An API client for the post recommendation service. The recommendation service
# is a separate Python microservice that generates recommended posts for users
# and posts. This client merely fetches the pre-generated recommendations from
# the service.
#
# Recommendations are generated based on user favorites using the Python
# `implicit` library.
#
# @see https://github.com/evazion/recommender
# @see https://github.com/benfred/implicit
# @see RecommendedPostsController
module RecommenderService
  module_function

  MIN_POST_FAVS = 5
  MIN_USER_FAVS = 50
  CACHE_LIFETIME = 5.minutes

  def enabled?
    Danbooru.config.recommender_server.present?
  end

  # @return [Boolean] True if the post has recommendations. Posts without enough
  #   favorites aren't generated recommendations.
  def available_for_post?(post)
    enabled? && post.fav_count > MIN_POST_FAVS
  end

  # @return [Boolean] True if the user has recommendations. Users without enough
  #   favorites aren't generated recommendations.
  def available_for_user?(user)
    enabled? && user.favorite_count > MIN_USER_FAVS
  end

  # Return a set of recommended posts for a user.
  # @param user [User] the user to get recommendations for
  # @param tags [String] a tag search to filter recommendations by
  # @param limit [Integer] the maximum number of recommendations to get
  # @return [Hash] The recommended posts. A hash with `score` and `post` keys.
  def recommend_for_user(user, tags: nil, limit: 50)
    response = Danbooru::Http.cache(CACHE_LIFETIME).get("#{Danbooru.config.recommender_server}/recommend/#{user.id}", params: { limit: limit })
    return [] if response.status != 200

    process_recs(response.parse, tags: tags, uploader: user, favoriter: user)
  end

  # Return a set of recommended posts for a post.
  # @param post [Post] the post to get recommendations for
  # @param tags [String] a tag search to filter recommendations by
  # @param limit [Integer] the maximum number of recommendations to get
  # @return [Hash] The recommended posts. A hash with `score` and `post` keys.
  def recommend_for_post(post, tags: nil, limit: 50)
    response = Danbooru::Http.cache(CACHE_LIFETIME).get("#{Danbooru.config.recommender_server}/similar/#{post.id}", params: { limit: limit })
    return [] if response.status != 200

    process_recs(response.parse, post: post, tags: tags)
  end

  # Process a set of recommendations to filter out posts the user uploaded
  # themselves, or has already favorited, or that don't match a tag search.
  def process_recs(recs, post: nil, uploader: nil, favoriter: nil, tags: nil)
    posts = Post.includes(:media_asset).where(id: recs.map(&:first))
    posts = posts.where.not(id: post.id) if post
    posts = posts.where.not(uploader_id: uploader.id) if uploader
    posts = posts.where.not(id: favoriter.favorites.select(:post_id)) if favoriter
    posts = posts.where(id: Post.user_tag_match(tags).reorder(nil).select(:id)) if tags.present?

    id_to_score = recs.to_h
    recs = posts.map { |post| { score: id_to_score[post.id], post: post } }
    recs = recs.sort_by { |rec| -rec[:score] }
    recs
  end

  # Handle the RecommendedPostsController#index method.
  def search(params)
    if params[:user_name].present?
      user = User.find_by_name(params[:user_name])
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
    elsif params[:post_id].present?
      post = Post.find(params[:post_id])
    end

    if user.present?
      raise User::PrivilegeError unless Pundit.policy!(CurrentUser.user, user).can_see_favorites?
      max_recommendations = params.fetch(:max_recommendations, user.favorite_count + 500).to_i.clamp(0, 50_000)
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
