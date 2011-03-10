class TagAliasesController < ApplicationController
  before_filter :admin_only, :only => [:new, :edit, :create, :update, :destroy]
  respond_to :html, :xml, :json
  
  def new
    @tag_alias = TagAlias.new(params[:tag_alias])
    respond_with(@tag_alias)
  end
  
  def edit
    @tag_alias = TagAlias.find(params[:id])
    respond_with(@tag_alias)
  end
  
  def index
    @search = TagAlias.search(params[:search])
    @tag_aliases = @search.paginate(:page => params[:page])
    respond_with(@tag_aliases)
  end
  
  def create
    @tag_alias = TagAlias.create(params[:tag_alias])
    respond_with(@tag_alias)
  end
  
  def update
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.update_attributes(params[:tag_alias])
    respond_with(@tag_alias)
  end
  
  def destroy
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.destroy
    respond_with(@tag_alias)
  end
  
  def cache
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.clear_cache
    render :nothing => true
  end
end
