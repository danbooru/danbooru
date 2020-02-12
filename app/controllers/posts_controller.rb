class PostsController < ApplicationController
  before_action :member_only, :except => [:show, :show_seq, :index, :home, :random]
  respond_to :html, :xml, :json
  layout "sidebar"

  def index
    if params[:md5].present?
      @post = Post.find_by!(md5: params[:md5])
      respond_with(@post) do |format|
        format.html { redirect_to(@post) }
      end
    else
      @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit], raw: params[:raw], random: params[:random], format: params[:format])
      @posts = @post_set.posts = @post_set.posts.includes(model_includes(params)) if !@post_set.is_random?
      respond_with(@posts) do |format|
        format.atom
      end
    end
  end

  def show
    @post = Post.find(params[:id])

    if request.format == Mime::Type.lookup("text/html")
      @comments = @post.comments
      @comments = @comments.includes(:creator)
      @comments = @comments.includes(:votes) if CurrentUser.is_member?
      @comments = @comments.visible(CurrentUser.user)

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
    context = PostSearchContext.new(params)
    if context.post_id
      redirect_to(post_path(context.post_id, q: params[:q]))
    else
      redirect_to(post_path(params[:id], q: params[:q]))
    end
  end

  def update
    @post = Post.find(params[:id])

    @post.update(post_params) if @post.visible?
    respond_with_post_after_update(@post)
  end

  def revert
    @post = Post.find(params[:id])
    @version = @post.versions.find(params[:version_id])

    if @post.visible?
      @post.revert_to!(@version)
    end

    respond_with(@post) do |format|
      format.js
    end
  end

  def copy_notes
    @post = Post.find(params[:id])
    @other_post = Post.find(params[:other_post_id].to_i)
    @post.copy_notes_to(@other_post)

    if @post.errors.any?
      @error_message = @post.errors.full_messages.join("; ")
      render :json => {:success => false, :reason => @error_message}.to_json, :status => 400
    else
      head :no_content
    end
  end

  def random
    @post = Post.tag_match(params[:tags]).random
    raise ActiveRecord::RecordNotFound if @post.nil?
    respond_with(@post) do |format|
      format.html { redirect_to post_path(@post, :tags => params[:tags]) }
    end
  end

  def mark_as_translated
    @post = Post.find(params[:id])
    @post.mark_as_translated(params[:post])
    respond_with_post_after_update(@post)
  end

  private

  def default_includes(params)
    if ["json", "xml", "atom"].include?(params[:format])
      [:uploader]
    else
      (CurrentUser.user.is_moderator? ? [:uploader] : [])
    end
  end

  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end

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

  def post_params
    permitted_params = %i[
      tag_string old_tag_string
      parent_id old_parent_id
      source old_source
      rating old_rating
      has_embedded_notes
    ]
    permitted_params += %i[is_rating_locked is_note_locked] if CurrentUser.is_builder?
    permitted_params += %i[is_status_locked] if CurrentUser.is_admin?

    params.require(:post).permit(permitted_params)
  end
end
