class PostVersionsController < ApplicationController
  def index
    @search = PostVersion.search(params[:search])
    @post_versions = @search.order("id desc").paginate(params[:page])
  end
end
