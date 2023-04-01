# frozen_string_literal: true

class ReactionsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @reactions = authorize Reaction.visible(CurrentUser.user).paginated_search(params, count_pages: true)

    respond_with(@reactions)
  end

  def show
    @reaction = authorize Reaction.find(params[:id])
    respond_with(@reaction)
  end

  def create
    @reaction = authorize Reaction.new(creator: CurrentUser.user, **permitted_attributes(Reaction))
    @reaction.save
    respond_with(@reaction)
  end

  def destroy
    @reaction = authorize Reaction.find(params[:id])
    @reaction.destroy
    respond_with(@reaction)
  end
end
