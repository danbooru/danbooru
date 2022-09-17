# frozen_string_literal: true

class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json

  def show
    @ip_address = authorize IpAddress.new(ip_addr: params[:id])
    @ip_info = @ip_address.ip_addr.ip_info
    respond_with(@ip_info)
  end
end
