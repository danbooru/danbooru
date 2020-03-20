class PostReplacementsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @post_replacement = authorize PostReplacement.new(post_id: params[:post_id], **permitted_attributes(PostReplacement))
    respond_with(@post_replacement)
  end

  def create
    @post = authorize Post.find(params[:post_id]), policy_class: PostReplacementPolicy
    @post_replacement = @post.replace!(permitted_attributes(PostReplacement))

    flash[:notice] = "Post replaced"
    respond_with(@post_replacement, location: @post)
  end

  def update
    @post_replacement = authorize PostReplacement.find(params[:id])
    @post_replacement.update(permitted_attributes(@post_replacement))

    respond_with(@post_replacement)
  end

  def index
    params[:search][:post_id] = params.delete(:post_id) if params.key?(:post_id)
    @post_replacements = authorize PostReplacement.paginated_search(params)
    @post_replacements = @post_replacements.includes(:creator, post: :uploader) if request.format.html?

    respond_with(@post_replacements)
  end
end
