class TagsController < ApplicationController
  before_action :member_only, :only => [:edit, :update]
  respond_to :html, :xml, :json

  def edit
    @tag = Tag.find(params[:id])
    check_privilege(@tag)
    respond_with(@tag)
  end

  def index
    @tags = Tag.paginated_search(params).includes(model_includes(params))
    respond_with(@tags)
  end

  def autocomplete
    if CurrentUser.is_builder?
      # limit rollout
      @tags = TagAutocomplete.search(params[:search][:name_matches])
    else
      @tags = Tag.names_matches_with_aliases(params[:search][:name_matches], params.fetch(:limit, 10).to_i)
    end

    # XXX
    respond_with(@tags.map(&:attributes))
  end

  def show
    @tag = Tag.find(params[:id])
    respond_with(@tag)
  end

  def update
    @tag = Tag.find(params[:id])
    check_privilege(@tag)
    @tag.update(tag_params)
    respond_with(@tag)
  end

  private

  def check_privilege(tag)
    raise User::PrivilegeError unless tag.editable_by?(CurrentUser.user)
  end

  def tag_params
    permitted_params = [:category]
    permitted_params << :is_locked if CurrentUser.is_moderator?

    params.require(:tag).permit(permitted_params)
  end
end
