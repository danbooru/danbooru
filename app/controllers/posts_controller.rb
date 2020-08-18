class PostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  layout "sidebar"

  def index
    if params[:md5].present?
      @post = authorize Post.find_by!(md5: params[:md5])
      respond_with(@post) do |format|
        format.html { redirect_to(@post) }
      end
    else
      tag_query = params[:tags] || params.dig(:post, :tags)
      @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit], random: params[:random], format: params[:format])
      @posts = authorize @post_set.posts, policy_class: PostPolicy
      respond_with(@posts) do |format|
        format.atom
      end
    end
  end

  def show
    @post = authorize Post.find(params[:id])

    if request.format.html?
      @comments = @post.comments
      @comments = @comments.includes(:creator)
      @comments = @comments.includes(:votes) if CurrentUser.is_member?
      @comments = @comments.unhidden(CurrentUser.user)

      include_deleted = @post.is_deleted? || (@post.parent_id.present? && @post.parent.is_deleted?) || CurrentUser.user.show_deleted_children?
      @sibling_posts = @post.parent.present? ? @post.parent.children : Post.none
      @sibling_posts = @sibling_posts.undeleted unless include_deleted

      @child_posts = @post.children
      @child_posts = @child_posts.undeleted unless include_deleted
    end

    respond_with(@post) do |format|
      format.html.tooltip { render layout: false }
    end
  end

  def show_seq
    authorize Post
    context = PostSearchContext.new(params)
    if context.post_id
      redirect_to(post_path(context.post_id, q: params[:q]))
    else
      redirect_to(post_path(params[:id], q: params[:q]))
    end
  end

  def update
    @post = authorize Post.find(params[:id])
    @post.update(permitted_attributes(@post))
    respond_with_post_after_update(@post)
  end

  def destroy
    @post = authorize Post.find(params[:id])

    if params[:commit] == "Delete"
      move_favorites = params.dig(:post, :move_favorites).to_s.truthy?
      @post.delete!(params.dig(:post, :reason), move_favorites: move_favorites, user: CurrentUser.user)
      flash[:notice] = "Post deleted"
    end

    respond_with_post_after_update(@post)
  end

  def revert
    @post = authorize Post.find(params[:id])
    @version = @post.versions.find(params[:version_id])
    @post.revert_to!(@version)

    respond_with(@post) do |format|
      format.js
    end
  end

  def copy_notes
    @post = Post.find(params[:id])
    @other_post = authorize Post.find(params[:other_post_id].to_i)
    @post.copy_notes_to(@other_post)

    if @post.errors.any?
      @error_message = @post.errors.full_messages.join("; ")
      render :json => {:success => false, :reason => @error_message}.to_json, :status => 400
    else
      head :no_content
    end
  end

  def random
    @post = Post.user_tag_match(params[:tags]).random
    raise ActiveRecord::RecordNotFound if @post.nil?
    authorize @post
    respond_with(@post) do |format|
      format.html { redirect_to post_path(@post, :tags => params[:tags]) }
    end
  end

  def mark_as_translated
    @post = authorize Post.find(params[:id])
    @post.mark_as_translated(params[:post])
    respond_with_post_after_update(@post)
  end

  private

  def respond_with_post_after_update(post)
    respond_with(post) do |format|
      format.html do
        if post.warnings.any?
          flash[:notice] = post.warnings.full_messages.join(".\n \n")
        end

        if post.errors.any?
          @error_message = post.errors.full_messages.join("; ")
          render :template => "static/error", :status => 500
        else
          response_params = {:q => params[:tags_query], :pool_id => params[:pool_id], :favgroup_id => params[:favgroup_id]}
          response_params.reject! {|key, value| value.blank?}
          redirect_to post_path(post, response_params)
        end
      end

      format.json do
        render :json => post.to_json
      end
    end
  end
end
