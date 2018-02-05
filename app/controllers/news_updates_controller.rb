class NewsUpdatesController < ApplicationController
  before_filter :admin_only
  respond_to :html

  def index
    @news_updates = NewsUpdate.order("id desc").paginate(params[:page], :limit => params[:limit])
    respond_with(@news_updates)
  end

  def edit
    @news_update = NewsUpdate.find(params[:id])
    respond_with(@news_update)
  end

  def update
    @news_update = NewsUpdate.find(params[:id])
    @news_update.update(news_update_params)
    respond_with(@news_update, :location => news_updates_path)
  end

  def new
    @news_update = NewsUpdate.new
    respond_with(@news_update)
  end

  def create
    @news_update = NewsUpdate.create(news_update_params)
    respond_with(@news_update, :location => news_updates_path)
  end

  def destroy
    @news_update = NewsUpdate.find(params[:id])
    @news_update.destroy
    respond_with(@news_update) do |format|
      format.js
    end
  end

  private

  def news_update_params
    params.require(:news_update).permit([:message])
  end
end
