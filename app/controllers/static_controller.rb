class StaticController < ApplicationController
  def terms_of_service
  end

  def not_found
    render plain: "not found", status: :not_found
  end

  def error
  end

  def dtext_help
    redirect_to wiki_page_path("help:dtext") unless request.format.js?
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
