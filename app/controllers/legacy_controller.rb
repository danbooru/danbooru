class LegacyController < ApplicationController
  def posts
    @post_set = PostSets::Post.new(tag_query, params[:page], params[:limit])
    @posts = @post_set.posts
  end
  
  def users
    @users = User.search(params).limit(100)
  end
  
  def tags
    @tags = Tag.search(params).limit(100)
  end

private
  def tag_query
    params[:tags] || (params[:post] && params[:post][:tags])
  end
end
