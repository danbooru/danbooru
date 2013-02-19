class PostVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @search = PostVersion.search(params[:search])
    @post_versions = @search.order("updated_at desc").paginate(params[:page], :count => 1_000_000)
    respond_with(@post_versions)
  end
  
  def search
  end
end
