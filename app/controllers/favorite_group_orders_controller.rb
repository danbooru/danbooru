class FavoriteGroupOrdersController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only

  def edit
    @favorite_group = FavoriteGroup.find(params[:favorite_group_id])
    respond_with(@favorite_group)
  end
end
