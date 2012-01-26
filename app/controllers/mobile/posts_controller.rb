module Mobile
  class PostsController < ApplicationController
    before_filter :member_only, :except => [:show, :index]
    respond_to :html
    rescue_from PostSets::SearchError, :with => :search_error
    layout "mobile"
  
    def index
      @post_set = PostSets::Post.new(tag_query, params[:page])
      @posts = @post_set.posts
    end
  
    def show
      @post = Post.find(params[:id])
    end

  private
    def search_error(exception)
      @exception = exception
      render :action => "error"
    end
  
    def tag_query
      params[:tags] || (params[:post] && params[:post][:tags])
    end

    def save_recent_tags
      if tag_query
        tags = Tag.scan_tags(tag_query)
        tags = TagAlias.to_aliased(tags) + Tag.scan_tags(session[:recent_tags])
        session[:recent_tags] = tags.uniq.slice(0, 40).join(" ")
      end
    end
  end
end
