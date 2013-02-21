class PostVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @post_versions = PostVersion.search(params[:search]).order("updated_at desc").paginate(params[:page], :count => (params[:search].present? ? nil : 1_000_000))
    respond_with(@post_versions)
  end
  
  def search
  end
end
