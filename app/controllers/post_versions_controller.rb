class PostVersionsController < ApplicationController
  def index
    @search = PostVersion.search(params[:search]).paginate(params[:paginate])
  end
end
