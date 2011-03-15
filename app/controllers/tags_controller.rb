class TagsController < ApplicationController
  before_filter :member_only, :only => [:edit, :update]
  respond_to :html, :xml, :json
  
  def edit
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end
  
  def index
    @search = Tag.search(params[:search])
    @tags = @search.paginate(:page => params[:page])
    respond_with(@tags)
  end
  
  def search
    @search = Tag.search(params[:search])
  end
  
  def show
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end

  def update
    @tag = Tag.find(params[:id])
    @tag.update_attributes(params[:tag])
    respond_with(@tag)
  end  
end
