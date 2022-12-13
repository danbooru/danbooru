# frozen_string_literal: true

class BackgroundJobPolicy < ApplicationPolicy
  def index?
    true
  end

  def update?
    user.is_admin?
  end

  def can_see_params?
    user.is_admin?
  end

  alias_method :cancel?, :update?
  alias_method :destroy?, :update?
  alias_method :retry?, :update?
  alias_method :run?, :update?

  def api_attributes
    attributes = super
    attributes -= [:serialized_params] unless can_see_params?
    attributes + [:job_duration, :queue_delay]
  end
end
