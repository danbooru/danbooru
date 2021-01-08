class IpGeolocationPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end
end
