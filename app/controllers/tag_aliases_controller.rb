class TagAliasesController < ApplicationController
  before_action :admin_only, only: [:destroy]
  respond_to :html, :xml, :json, :js

  def show
    @tag_alias = TagAlias.find(params[:id])
    respond_with(@tag_alias)
  end

  def index
    @tag_aliases = TagAlias.paginated_search(params, count_pages: true)
    @tag_aliases = @tag_aliases.includes(:antecedent_tag, :consequent_tag, :approver) if request.format.html?

    respond_with(@tag_aliases)
  end

  def destroy
    @tag_alias = TagAlias.find(params[:id])
    @tag_alias.reject!

    respond_with(@tag_alias, location: tag_aliases_path, notice: "Tag alias was deleted")
  end

  private

  def tag_alias_params
    params.require(:tag_alias).permit(%i[antecedent_name consequent_name forum_topic_id skip_secondary_validations])
  end
end
