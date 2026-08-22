# frozen_string_literal: true

class EmailNotificationPolicy < ApplicationPolicy
  # Override the parent method from ApplicationPolicy to ensure that users can always access the unsubscribe links.
  # This is a public-facing endpoint that needs to remain accessible regardless of the force_authenticated setting.
  def show?
    true
  end

  def destroy?
    true
  end

  alias_method :create?, :destroy?
end
