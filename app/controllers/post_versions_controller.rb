class PostVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @search = PostVersion.search(params[:search])
    @post_versions = @search.order("id desc").paginate_sequential(params[:page])
    respond_with(@post_versions)
  end
  
  def search
  end
end
