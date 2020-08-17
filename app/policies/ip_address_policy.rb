class IpAddressPolicy < ApplicationPolicy
  def index?
    user.is_moderator?
  end

  def html_data_attributes
    super & attributes.keys.map(&:to_sym)
  end
end
