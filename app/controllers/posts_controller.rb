class PostsController < ApplicationController
  before_filter :member_only, :except => [:show, :show_seq, :index]
  before_filter :builder_only, :only => [:copy_notes]
  after_filter :save_recent_tags, :only => [:update]
  respond_to :html, :xml, :json
  rescue_from PostSets::SearchError, :with => :rescue_exception
  rescue_from Post::SearchError, :with => :rescue_exception
  rescue_from ActiveRecord::StatementInvalid, :with => :rescue_exception
  rescue_from ActiveRecord::RecordNotFound, :with => :rescue_exception

  def index
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit] || CurrentUser.user.per_page, params[:raw])
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
    @parent_post_set = PostSets::PostRelationship.new(@post.parent_id, :include_deleted => @post.is_deleted?)
    @children_post_set = PostSets::PostRelationship.new(@post.id, :include_deleted => @post.is_deleted?)
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

  def copy_notes
    @post = Post.find(params[:id])
    @other_post = Post.find(params[:other_post_id].to_i)
    @post.copy_notes_to(@other_post)
    render :nothing => true
  end

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end

  def save_recent_tags
    if @post
      tags = Tag.scan_tags(@post.tag_string)
      tags = (TagAlias.to_aliased(tags) + Tag.scan_tags(cookies[:recent_tags])).uniq.slice(0, 30)
      cookies[:recent_tags] = tags.join(" ")
      cookies[:recent_tags_with_categories] = Tag.categories_for(tags).to_a.flatten.join(" ")
    end
  end
end
