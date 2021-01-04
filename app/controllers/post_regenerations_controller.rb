class PostRegenerationsController < ApplicationController
  respond_to :xml, :json, :js

  def create
    @post = authorize Post.find(params[:post_id]), :regenerate?
    @post.regenerate!(params[:category], CurrentUser.user)

    respond_with(@post)
  end
end
