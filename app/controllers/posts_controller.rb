class PostsController < ApplicationController
  before_filter :member_only, :except => [:show, :index]
  after_filter :save_recent_tags, :only => [:update]
  respond_to :html, :xml, :json
  rescue_from PostSets::SearchError, :with => :search_error
  rescue_from Post::SearchError, :with => :search_error
  rescue_from Danbooru::Paginator::PaginationError, :with => :search_error
  
  def index
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit])
    @posts = @post_set.posts
    respond_with(@posts) do |format|
      format.atom
    end
  rescue ::ActiveRecord::StatementInvalid => e
    if e.to_s =~ /statement timeout/
      @error_message = "The database timed out running your query. Try a simpler query that returns fewer results."
      render :action => "error"
    else
      raise
    end
  end
  
  def show
    @post = Post.find(params[:id])
    @post_flag = PostFlag.new(:post_id => @post.id)
    @post_appeal = PostAppeal.new(:post_id => @post.id)
    respond_with(@post)
  end
  
  def update
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post], :as => CurrentUser.role)
    respond_with(@post) do |format|
      format.json do
        render :json => @post.to_json
      end
    end
  end
  
  def revert
    @post = Post.find(params[:id])
    @version = PostVersion.find(params[:version_id])
    @post.revert_to!(@version)
    respond_with(@post) do |format|
      format.js
    end
  end
  
  def error
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
