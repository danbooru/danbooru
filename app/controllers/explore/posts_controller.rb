module Explore
  class PostsController < ApplicationController
    respond_to :html, :xml, :json

    def popular
      @post_set = PostSets::Popular.new(params[:date], params[:scale])
      @posts = @post_set.posts
      respond_with(@posts)
    end
  end
end
