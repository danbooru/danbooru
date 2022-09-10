# frozen_string_literal: true

class TagsController < ApplicationController
  respond_to :html, :xml, :json

  def edit
    @tag = authorize Tag.find(params[:id])
    respond_with(@tag)
  end

  def index
    if request.format.html?
      @tags = authorize Tag.paginated_search(params, defaults: { hide_empty: true })
    else
      @tags = authorize Tag.paginated_search(params)
    end

    @tags = @tags.includes(:consequent_aliases) if request.format.html?
    respond_with(@tags)
  end

  def show
    @tag = authorize Tag.find(params[:id])
    respond_with(@tag)
  end

  def update
    @tag = authorize Tag.find(params[:id])
    @tag.update(updater: CurrentUser.user, **permitted_attributes(@tag))
    respond_with(@tag)
  end
end
