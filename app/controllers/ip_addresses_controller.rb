class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :moderator_only

  def index
    if search_params[:group_by] == "ip_addr"
      @ip_addresses = IpAddress.search(search_params).group_by_ip_addr
      respond_with(@ip_addresses)
    elsif search_params[:group_by] == "user"
      @ip_addresses = IpAddress.search(search_params).group_by_user
      respond_with(@ip_addresses)
    else
      @ip_addresses = IpAddress.includes(:user, :model).paginated_search(params)
      respond_with(@ip_addresses)
    end
  end
end
