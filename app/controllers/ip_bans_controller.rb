class IpBansController < ApplicationController
  before_filter :janitor_only

  def new
    @ip_ban = IpBan.new
  end

  def create
    @ip_ban = IpBan.create(params[:ip_ban])
    redirect_to ip_bans_path
  end
  
  def index
    @search = IpBan.search(params[:search])
    @ip_bans = @search.order("id desc").paginate(params[:page])
  end
  
  def destroy
    @ip_ban = IpBan.find(params[:id])
    @ip_ban.destroy
  end
end
