class CountsController < ApplicationController
  respond_to :xml, :json

  def posts
    @count = Post.fast_count(
      params[:tags], 
      timeout: CurrentUser.statement_timeout, 
      raise_on_timeout: true,
      skip_cache: params[:skip_cache]
    )
  end
end
