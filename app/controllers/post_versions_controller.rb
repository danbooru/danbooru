class PostVersionsController < ApplicationController
  def index
    @search = PostVersion.search(params[:search])
    @post_versions = @search.paginate(:page => params[:page], :order => "updated_at DESC")
  end
end
