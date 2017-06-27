class PostReplacementsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :approver_only, except: [:index]

  def new
    @post = Post.find(params[:post_id])
  end

  def create
    @post = Post.find(params[:post_id])
    @post_replacement = @post.replace!(create_params)

    flash[:notice] = "Post replaced"
    respond_with(@post_replacement, location: @post)
  end

  def index
    params[:search][:post_id] = params.delete(:post_id) if params.has_key?(:post_id)
    @post_replacements = PostReplacement.search(params[:search]).paginate(params[:page], limit: params[:limit])

    respond_with(@post_replacements)
  end

private
  def create_params
    params.require(:post_replacement).permit(:replacement_url, :replacement_file, :final_source, :tags)
  end
end
