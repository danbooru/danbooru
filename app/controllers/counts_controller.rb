class CountsController < ApplicationController
  respond_to :xml, :json
  rescue_from Post::TimeoutError, with: :rescue_exception

  def posts
    @count = Post.fast_count(params[:tags], raise_on_timeout: true)
  end
end
