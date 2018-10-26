class ModActionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @mod_actions = ModAction.search(search_params).paginate(params[:page], :limit => params[:limit])
    respond_with(@mod_actions)
  end

  def show
    @mod_action = ModAction.find(params[:id])
    respond_with(@mod_action) do |fmt|
      fmt.html { redirect_to mod_actions_path(search: { id: @mod_action.id }) }
    end
  end
end
