# frozen_string_literal: true

class ServerStatusPolicy < ApplicationPolicy
  # Whether the user can see sensitive server info, such as software versions or Postgres info.
  def can_see_sensitive_info?
    user.is_superadmin?
  end

  # Rate limits are stored in the database, so don't apply one when the database is down.
  def rate_limit_for_show(**_options)
    return {} unless record.postgres_up?

    { rate: 2.0 / 1.second, burst: 10 }
  end
end
