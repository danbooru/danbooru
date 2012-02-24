class ModActionsController < ApplicationController
  def index
    @mod_actions = ModAction.search(params[:search]).order("id desc").paginate(params[:page])
  end
end
