class PostsController < ApplicationController
  before_filter :member_only, :except => [:show, :show_seq, :index]
  after_filter :save_recent_tags, :only => [:update]
  respond_to :html, :xml, :json
  rescue_from PostSets::SearchError, :with => :rescue_exception
  rescue_from Post::SearchError, :with => :rescue_exception
  rescue_from ActiveRecord::StatementInvalid, :with => :rescue_exception
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_exception

  def index
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit] || CurrentUser.user.per_page)
    @posts = @post_set.posts
    respond_with(@posts) do |format|
      format.atom
      format.xml do
        render :xml => @posts.to_xml(:root => "posts")
      end
    end
  end

  def show
    @post = Post.find(params[:id])
    @post_flag = PostFlag.new(:post_id => @post.id)
    @post_appeal = PostAppeal.new(:post_id => @post.id)

    @children_post_set = PostSets::Post.new("parent:#{@post.id} -id:#{@post.id}", 1, 200)
    @children_post_set.posts.reverse!
    @parent_post_set = PostSets::Post.new("id:#{@post.parent_id} status:any")
    @siblings_post_set = PostSets::Post.new("parent:#{@post.parent_id} -id:#{@post.parent_id}", 1, 200)
    @siblings_post_set.posts.reverse!

    respond_with(@post)
  end

  def show_seq
    context = PostSearchContext.new(params)
    if context.post_id
      redirect_to(post_path(context.post_id, :tags => params[:tags]))
    else
      redirect_to(post_path(params[:id], :tags => params[:tags]))
    end
  end

  def update
    @post = Post.find(params[:id])

    if Danbooru.config.can_user_see_post?(CurrentUser.user, @post)
      @post.update_attributes(params[:post], :as => CurrentUser.role)
    end

    respond_with(@post) do |format|
      format.html do
        if @post.errors.any?
          @error_message = @post.errors.full_messages.join("; ")
          render :template => "static/error", :status => 500
        elsif params[:tags].present? && params[:pool_id].present?
          redirect_to post_path(@post, :tags => params[:tags], :pool_id => params[:pool_id])
        elsif params[:tags].present?
          redirect_to post_path(@post, :tags => params[:tags])
        elsif params[:pool_id].present?
          redirect_to post_path(@post, :pool_id => params[:pool_id])
        else
          redirect_to post_path(@post)
        end
      end

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

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end

  def save_recent_tags
    if @post
      tags = Tag.scan_tags(@post.tag_string)
      tags = TagAlias.to_aliased(tags) + Tag.scan_tags(cookies[:recent_tags])
      cookies[:recent_tags] = tags.uniq.slice(0, 40).join(" ")
    end
  end
end
