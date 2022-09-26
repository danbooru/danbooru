# frozen_string_literal: true

class ModActionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @mod_actions = ModAction.visible(CurrentUser.user).paginated_search(params)

    if request.format.html?
      @mod_actions = @mod_actions.includes(:creator, :subject)
      @dtext_data = DText.preprocess(@mod_actions.map(&:description))
    end

    respond_with(@mod_actions)
  end

  def show
    @mod_action = ModAction.find(params[:id])
    respond_with(@mod_action) do |fmt|
      fmt.html { redirect_to mod_actions_path(search: { id: @mod_action.id }) }
    end
  end
end
