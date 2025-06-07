# frozen_string_literal: true

class DmcaPolicy < ApplicationPolicy
  def create?
    true
  end

  alias_method :template?, :show?
end
