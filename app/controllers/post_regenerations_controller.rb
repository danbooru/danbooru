class PostRegenerationsController < ApplicationController
  respond_to :xml, :json, :html

  def create
    @post = authorize Post.find(params[:post_id]), :regenerate?
    @post.regenerate_later!(params[:category], CurrentUser.user)
    flash[:notice] = "Post regeneration scheduled, press Ctrl+F5 in a few seconds to refresh the image"

    respond_with(@post)
  end
end
