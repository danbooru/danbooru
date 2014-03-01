class TagAliasesController < ApplicationController
  before_filter :admin_only, :only => [:approve, :new, :create]
  respond_to :html, :xml, :json, :js

  def show
    @tag_alias = TagAlias.find(params[:id])
    respond_with(@tag_alias)
  end

  def new
    @tag_alias = TagAlias.new(params[:tag_alias])
    respond_with(@tag_alias)
  end

  def index
    @search = TagAlias.search(params[:search])
    @tag_aliases = @search.order("(case status when 'pending' then 0 when 'queued' then 1 else 2 end), antecedent_name, consequent_name").paginate(params[:page], :limit => params[:limit])
    respond_with(@tag_aliases) do |format|
      format.xml do
        render :xml => @tag_aliases.to_xml(:root => "tag-aliases")
      end
    end
  end

  def create
    @tag_alias = TagAlias.create(params[:tag_alias])
    respond_with(@tag_alias, :location => tag_aliases_path(:search => {:id => @tag_alias.id}))
  end

  def destroy
    @tag_alias = TagAlias.find(params[:id])
    if @tag_alias.deletable_by?(CurrentUser.user)
      @tag_alias.update_column(:status, "deleted")
      @tag_alias.clear_all_cache
      @tag_alias.destroy
      respond_with(@tag_alias, :location => tag_aliases_path)
    else
      access_denied
    end
  end

  def approve
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.update_column(:status, "queued")
    @tag_alias.delay(:queue => "default").process!
    respond_with(@tag_alias, :location => tag_alias_path(@tag_alias))
  end
end
