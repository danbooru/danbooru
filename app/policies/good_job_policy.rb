# frozen_string_literal: true

class GoodJobPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    user.is_admin?
  end

  alias_method :cancel?, :update?
  alias_method :destroy?, :update?
  alias_method :retry?, :update?
  alias_method :run?, :update?
end
