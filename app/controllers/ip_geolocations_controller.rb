# frozen_string_literal: true

class IpGeolocationsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @ip_geolocations = authorize IpGeolocation.visible(CurrentUser.user).paginated_search(params, count_pages: true)

    respond_with(@ip_geolocations)
  end
end
