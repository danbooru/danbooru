class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :moderator_only

  def index
    if search_params[:group_by] == "ip_addr"
      @ip_addresses = IpAddress.search(search_params).group_by_ip_addr(search_params[:ipv4_masklen], search_params[:ipv6_masklen]).paginate(params[:page], limit: params[:limit] || 1000)
    elsif search_params[:group_by] == "user"
      @ip_addresses = IpAddress.includes(:user).search(search_params).group_by_user.paginate(params[:page], limit: params[:limit] || 1000)
    else
      @ip_addresses = IpAddress.includes(:user, :model).paginated_search(params)
    end

    respond_with(@ip_addresses)
  end
end
