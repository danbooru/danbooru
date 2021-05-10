class DelayedJobPolicy < ApplicationPolicy
  def update?
    user.is_admin?
  end

  alias_method :cancel?, :update?
  alias_method :destroy?, :update?
  alias_method :retry?, :update?
  alias_method :run?, :update?
end
