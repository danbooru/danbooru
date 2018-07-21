class RecommendedPostsController < ApplicationController
  before_action :member_only
  respond_to :html

  def show
    @posts = load_posts()

    if request.xhr?
      render partial: "show", layout: false
    end
  end

private

  def load_posts
    if params[:context] == "post"
      @posts = RecommenderService.recommend(post_id: params[:post_id].to_i)

    elsif params[:context] == "user"
      @posts = RecommenderService.recommend(user_id: CurrentUser.id)
    end
  end
end
