class PostVersionsController < ApplicationController
  def index
    @search = PostVersion.search(params[:search])
    @post_versions = @search.paginate(:page => params[:page], :per_page => 20, :order => "updated_at DESC")
  end
end
