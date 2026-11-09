# frozen_string_literal: true

class IpAddressesController < ApplicationController
  respond_to :html, :xml, :json

  # Allow the embedded Bing map.
  content_security_policy only: :show do |policy|
    policy.frame_src(*policy.directives["frame-src"], "https://www.bing.com")
  end

  def show
    @ip_address = authorize Danbooru::IpAddress.new(params[:id]), policy_class: IpAddressPolicy
    @ip_info = @ip_address.ip_info
    respond_with(@ip_info)
  end
end
