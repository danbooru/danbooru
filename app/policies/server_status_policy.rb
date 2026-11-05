# frozen_string_literal: true

class ServerStatusPolicy < ApplicationPolicy
  # Rate limits are stored in the database, so don't apply one when the database is down.
  def rate_limit_for_show(**_options)
    return {} unless record.postgres_up?

    { rate: 2.0 / 1.second, burst: 10 }
  end
end
