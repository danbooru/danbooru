module M
  class PostsController < ApplicationController
    layout "mobile"
    
    def index
      @post_set = PostSets::Post.new(params[:tags], params[:page])
      @posts = @post_set.posts
    end
    
    def show
      @post = Post.find(params[:id])
    end
  end
end
