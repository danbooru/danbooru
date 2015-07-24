module Explore
  class PostsController < ApplicationController
    respond_to :html, :xml, :json

    def popular
      @post_set = PostSets::Popular.new(params[:date], params[:scale])
      @posts = @post_set.posts
      respond_with(@posts)
    end

    def popular_view
      @post_set = PostSets::PopularView.new(params[:date], params[:scale])
      @posts = @post_set.posts
      respond_with(@posts)
    end

    def intro
      @presenter = IntroPresenter.new
      render :layout => "blank"
    end
  end
end
