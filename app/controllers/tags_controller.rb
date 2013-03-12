class TagsController < ApplicationController
  before_filter :member_only, :only => [:edit, :update]
  respond_to :html, :xml, :json
  
  def edit
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end
  
  def index
    @tags = Tag.search(params[:search]).paginate(params[:page], :search_count => params[:search])
    respond_with(@tags)
  end
  
  def search
  end
  
  def show
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    @tag.update_category_cache_for_all
    respond_with(@tag)
  end  
end
