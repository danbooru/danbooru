class PostReplacementsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :moderator_only, except: [:index]

  def new
    @post = Post.find(params[:post_id])
  end

  def create
    @post = Post.find(params[:post_id])
    @post_replacement = @post.replace!(create_params)

    flash[:notice] = "Post replaced"
    respond_with(@post_replacement, location: @post)
  end

  def update
    @post_replacement = PostReplacement.find(params[:id])
    @post_replacement.update(update_params)

    respond_with(@post_replacement)
  end

  def index
    params[:search][:post_id] = params.delete(:post_id) if params.has_key?(:post_id)
    @post_replacements = PostReplacement.search(search_params).paginate(params[:page], limit: params[:limit])

    respond_with(@post_replacements)
  end

private
  def create_params
    params.require(:post_replacement).permit(:replacement_url, :replacement_file, :final_source, :tags)
  end

  def update_params
    params.require(:post_replacement).permit(
      :file_ext_was, :file_size_was, :image_width_was, :image_height_was, :md5_was,
      :file_ext, :file_size, :image_width, :image_height, :md5,
      :original_url, :replacement_url
    )
  end
end
