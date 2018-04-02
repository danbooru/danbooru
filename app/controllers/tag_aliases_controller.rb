class TagAliasesController < ApplicationController
  before_action :admin_only, :only => [:approve, :new, :create]
  respond_to :html, :xml, :json, :js

  def show
    @tag_alias = TagAlias.find(params[:id])
    respond_with(@tag_alias)
  end

  def edit
    @tag_alias = TagAlias.find(params[:id])
  end

  def update
    @tag_alias = TagAlias.find(params[:id])

    if @tag_alias.is_pending? && @tag_alias.editable_by?(CurrentUser.user)
      @tag_alias.update(tag_alias_params)
    end

    respond_with(@tag_alias)
  end

  def index
    @tag_aliases = TagAlias.search(search_params).paginate(params[:page], :limit => params[:limit])
    respond_with(@tag_aliases) do |format|
      format.xml do
        render :xml => @tag_aliases.to_xml(:root => "tag-aliases")
      end
    end
  end

  def destroy
    @tag_alias = TagAlias.find(params[:id])
    if @tag_alias.deletable_by?(CurrentUser.user)
      @tag_alias.reject!
      respond_with(@tag_alias, :location => tag_aliases_path)
    else
      access_denied
    end
  end

  def approve
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.approve!(approver: CurrentUser.user)
    respond_with(@tag_alias, :location => tag_alias_path(@tag_alias))
  end

private

  def tag_alias_params
    params.require(:tag_alias).permit(%i[antecedent_name consequent_name forum_topic_id skip_secondary_validations])
  end
end
