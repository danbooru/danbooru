class IpBansController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :moderator_only

  def new
    @ip_ban = IpBan.new
  end

  def create
    @ip_ban = CurrentUser.ip_bans.create(ip_ban_params)
    respond_with(@ip_ban, :location => ip_bans_path)
  end

  def index
    @ip_bans = IpBan.paginated_search(params, count_pages: true).includes(model_includes(params))
    respond_with(@ip_bans)
  end

  def destroy
    @ip_ban = IpBan.find(params[:id])
    @ip_ban.destroy
    respond_with(@ip_ban)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:creator]
    end
  end

  def ip_ban_params
    params.fetch(:ip_ban, {}).permit(%i[ip_addr reason])
  end

  def search_params
    params.fetch(:search, {}).permit(%i[ip_addr order])
  end
end
