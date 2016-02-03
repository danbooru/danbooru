module Explore
  class PostsController < ApplicationController
    respond_to :html, :xml, :json

    def popular
      @post_set = PostSets::Popular.new(params[:date], params[:scale])
      @posts = @post_set.posts
      respond_with(@posts)
    end

    def searches
      @date = params[:date] ? Date.parse(params[:date]) : Date.today
      @search_service = PopularSearchService.new(@date, params[:scale] || "day")
    end

    def missed_searches
      @search_service = MissedSearchService.new
    end

    def intro
      @presenter = IntroPresenter.new
      render :layout => "blank"
    end
  end
end
