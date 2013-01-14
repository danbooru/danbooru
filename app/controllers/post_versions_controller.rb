class PostVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @search = PostVersion.search(params[:search])
    @post_versions = @search.order("id desc").paginate(params[:page])
    respond_with(@post_versions)
  end
  
  def search
    @search = PostVersion.search(params[:search])
  end
end
