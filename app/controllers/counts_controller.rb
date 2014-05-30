class CountsController < ApplicationController
  respond_to :xml, :json

  def posts
    @count = Post.fast_count(params[:tags], :statement_timeout => CurrentUser.user.statement_timeout)
  end
end
