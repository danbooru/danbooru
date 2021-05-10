class IpBansController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @ip_ban = authorize IpBan.new(permitted_attributes(IpBan))
    respond_with(@ip_ban)
  end

  def create
    @ip_ban = authorize IpBan.new(creator: CurrentUser.user, **permitted_attributes(IpBan))
    @ip_ban.save
    respond_with(@ip_ban, :location => ip_bans_path)
  end

  def index
    @ip_bans = authorize IpBan.paginated_search(params, count_pages: true)
    @ip_bans = @ip_bans.includes(:creator) if request.format.html?

    respond_with(@ip_bans)
  end

  def update
    @ip_ban = authorize IpBan.find(params[:id])
    @ip_ban.update(permitted_attributes(@ip_ban))

    respond_with(@ip_ban)
  end
end
