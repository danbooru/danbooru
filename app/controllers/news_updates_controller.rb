class NewsUpdatesController < ApplicationController
  respond_to :html

  def index
    authorize NewsUpdate
    @news_updates = NewsUpdate.order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@news_updates)
  end

  def edit
    @news_update = authorize NewsUpdate.find(params[:id])
    respond_with(@news_update)
  end

  def update
    @news_update = authorize NewsUpdate.find(params[:id])
    @news_update.update(permitted_attributes(@news_update))
    respond_with(@news_update, :location => news_updates_path)
  end

  def new
    @news_update = authorize NewsUpdate.new
    respond_with(@news_update)
  end

  def create
    @news_update = authorize NewsUpdate.new(creator: CurrentUser.user, **permitted_attributes(NewsUpdate))
    @news_update.save
    respond_with(@news_update, :location => news_updates_path)
  end

  def destroy
    @news_update = authorize NewsUpdate.find(params[:id])
    @news_update.destroy
    respond_with(@news_update) do |format|
      format.js
    end
  end
end
