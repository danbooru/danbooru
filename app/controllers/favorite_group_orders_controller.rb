class FavoriteGroupOrdersController < ApplicationController
  respond_to :html, :xml, :json, :js

  def edit
    @favorite_group = authorize FavoriteGroup.find(params[:favorite_group_id])
    respond_with(@favorite_group)
  end
end
