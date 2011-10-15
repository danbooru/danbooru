class ModActionsController < ApplicationController
  def index
    @mod_actions = ModAction.search(params[:search]).paginate(params[:page])
  end
end
