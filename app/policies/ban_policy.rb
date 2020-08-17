class BanPolicy < ApplicationPolicy
  def bannable?
    user.is_moderator? && (record.user.blank? || (record.user.level < user.level))
  end

  alias_method :edit?, :bannable?
  alias_method :create?, :bannable?
  alias_method :update?, :bannable?
  alias_method :destroy?, :bannable?

  def permitted_attributes_for_create
    [:reason, :duration, :expires_at, :user_id, :user_name]
  end

  def permitted_attributes_for_update
    [:reason, :duration, :expires_at]
  end

  def html_data_attributes
    super + [:expired?]
  end
end
