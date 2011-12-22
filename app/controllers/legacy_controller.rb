class LegacyController < ApplicationController
  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page])
    @posts = @post_set.posts
  end

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
