# frozen_string_literal: true

class IpGeolocationPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end
end
