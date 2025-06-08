# frozen_string_literal: true

class DmcaPolicy < ApplicationPolicy
  def create?
    true
  end

  def rate_limit_for_create(**_options)
    { rate: 1.0 / 15.minutes, burst: 3 }
  end

  alias_method :template?, :show?
end
