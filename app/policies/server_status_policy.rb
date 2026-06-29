# frozen_string_literal: true

class ServerStatusPolicy < ApplicationPolicy
  # Override the parent method from ApplicationPolicy to ensure that users can always access the server status page.
  # This is a public-facing endpoint that needs to remain accessible regardless of the force_authenticated setting.
  def show?
    true
  end
end
