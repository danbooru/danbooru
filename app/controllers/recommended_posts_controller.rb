class RecommendedPostsController < ApplicationController
  respond_to :html, :json, :xml, :js

  def show
    @max_recommendations = params.fetch(:max_recommendations, 100).to_i.clamp(0, 1000)

    if params[:user_id].present?
      @recs = RecommenderService.recommend_for_user(params[:user_id], @max_recommendations)
    elsif params[:post_id].present?
      @recs = RecommenderService.recommend_for_post(params[:post_id], @max_recommendations)
    else
      @recs = []
    end

    @posts = @recs.map { |rec| rec[:post] }
    respond_with(@recs)
  end
end
