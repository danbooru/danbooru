# frozen_string_literal: true

class EmailNotificationPolicy < ApplicationPolicy
  def destroy?
    true
  end

  alias_method :create?, :destroy?
end
