class CountsController < ApplicationController
  respond_to :xml, :json

  def posts
    @count = PostQueryBuilder.new(params[:tags]).fast_count(timeout: CurrentUser.statement_timeout, raise_on_timeout: true, skip_cache: params[:skip_cache])
  end
end
