class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json
  before_action :moderator_only

  def index
    @ip_addresses = IpAddress.visible(CurrentUser.user).paginated_search(params).includes(model_includes(params))

    if search_params[:group_by] == "ip_addr"
      @ip_addresses = @ip_addresses.group_by_ip_addr(search_params[:ipv4_masklen], search_params[:ipv6_masklen])
    elsif search_params[:group_by] == "user"
      @ip_addresses = @ip_addresses.group_by_user
    end

    respond_with(@ip_addresses)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      if params[:search][:group_by] == "user"
        [:user]
      elsif params[:search][:group_by] == "ip_addr"
        []
      else
        [:user, :model]
      end
    end
  end
end
