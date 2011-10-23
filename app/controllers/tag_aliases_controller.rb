class TagAliasesController < ApplicationController
  before_filter :admin_only, :only => [:approve, :destroy]
  before_filter :member_only, :only => [:create]
  respond_to :html, :xml, :json, :js
  
  def new
    @tag_alias = TagAlias.new(params[:tag_alias])
    respond_with(@tag_alias)
  end
  
  def index
    @search = TagAlias.search(params[:search])
    @tag_aliases = @search.order("(case status when 'pending' then 0 when 'queued' then 1 else 2 end), antecedent_name, consequent_name").paginate(params[:page])
    respond_with(@tag_aliases)
  end
  
  def create
    @tag_alias = TagAlias.create(params[:tag_alias])
    respond_with(@tag_alias, :location => tag_aliases_path(:search => {:id_eq => @tag_alias.id}))
  end
  
  def destroy
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.destroy
    respond_with(@tag_alias, :location => tag_aliases_path)
  end
  
  def approve
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.update_column(:status, "queued")
    @tag_alias.delay.process!
    respond_with(@tag_alias, :location => tag_alias_path(@tag_alias))
  end
  
  def cache
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.clear_cache
    render :nothing => true
  end
end
