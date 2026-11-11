# frozen_string_literal: true

class IpGeolocationPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def searchable_attributes
    %i[id created_at updated_at ip_addr network asn is_proxy latitude longitude organization time_zone continent country region city carrier]
  end
end
