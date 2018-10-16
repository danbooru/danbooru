class StaticController < ApplicationController
  def terms_of_service
  end
  
  def accept_terms_of_service
    cookies.permanent[:accepted_tos] = "1"
    url = params[:url] if params[:url] && params[:url].start_with?("/")
    redirect_to(url || posts_path)
  end

  def not_found
    render plain: "not found", status: :not_found
  end

  def error
  end

  def site_map
  end

  def sitemap
    @popular_search_service = PopularSearchService.new(Date.yesterday)
    @post_set = PostSets::Popular.new(Date.yesterday.to_s, "week", limit: 200)
    @posts = @post_set.posts
    render layout: false
  end  
end
