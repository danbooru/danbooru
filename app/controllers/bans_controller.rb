# frozen_string_literal: true

class BansController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @ban = authorize Ban.new(permitted_attributes(Ban))
    respond_with(@ban)
  end

  def edit
    @ban = authorize Ban.find(params[:id])
    respond_with(@ban)
  end

  def index
    @bans = authorize Ban.paginated_search(params, count_pages: true)
    @bans = @bans.includes(:user, :banner) if request.format.html?

    respond_with(@bans)
  end

  def show
    @ban = authorize Ban.find(params[:id])
    respond_with(@ban) do |format|
      format.html { redirect_to bans_path(search: { id: @ban.id }) }
    end
  end

  def create
    @ban = authorize Ban.new(banner: CurrentUser.user, **permitted_attributes(Ban))
    @ban.save
    respond_with(@ban, notice: "Banned user", location: @ban.user)
  end

  def update
    @ban = authorize Ban.find(params[:id])
    @ban.update(updater: CurrentUser.user, **permitted_attributes(@ban))
    respond_with(@ban, notice: "Ban updated", location: @ban.user)
  end

  def destroy
    @ban = authorize Ban.find(params[:id])
    @ban.updater = CurrentUser.user
    @ban.destroy
    respond_with(@ban, noticed: "Ban removed", location: @ban.user)
  end
end
