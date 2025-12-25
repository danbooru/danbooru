# frozen_string_literal: true

class RateLimit < ApplicationRecord
  scope :expired, -> { where("updated_at < ?", 1.hour.ago) }

  def self.prune!
    expired.delete_all
  end

  def self.visible(user)
    if user.is_owner?
      all
    elsif user.is_anonymous?
      none
    else
      where(key: [user.cache_key])
    end
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :limited, :points, :action, :key], current_user: current_user)
    q.apply_default_order(params)
  end

  # `action` is the action being limited. Usually a controller endpoint.
  # `keys` is who is being limited. Usually a [user, ip] pair, meaning the action is limited both by the user's ID and their IP.
  # `cost` is the number of points the action costs.
  # `rate` is the number of points per second that are refilled.
  # `burst` is the maximum number of points that can be saved up.
  def self.create_or_update!(action:, keys:, cost:, rate:, burst:, minimum_points: -30)
    # { key0: keys[0], ..., keyN: keys[N] }
    key_params = keys.map.with_index { |key, i| [:"key#{i}", key] }.to_h

    # (created_at, updated_at, action, keyN, points)
    values = keys.map.with_index { |_key, i| "(:now, :now, :action, :key#{i}, :limited, :points)" }

    # Do an upsert, creating a new rate limit object for each key that doesn't
    # already exist, and updating the limit for each limit that already exists.
    #
    # If the current point count is negative, then we're limited. Penalize the
    # caller 1 second (1 rate unit), up to a maximum penalty of 30 seconds (by default).
    #
    # Otherwise, if the point count is positive, then we're not limited. Update
    # the point count and subtract the cost of the call.
    #
    # https://www.postgresql.org/docs/current/sql-insert.html#SQL-ON-CONFLICT
    sql = <<~SQL.squish
      INSERT INTO rate_limits (created_at, updated_at, action, key, limited, points)
      VALUES #{values.join(", ")}
      ON CONFLICT (action, key) DO UPDATE SET
        updated_at = :now,
        limited = LEAST(:burst, rate_limits.points + :rate * EXTRACT(epoch FROM (:now - rate_limits.updated_at))) - :cost < 0,
        points =
          CASE
          WHEN rate_limits.points + :rate * EXTRACT(epoch FROM (:now - rate_limits.updated_at)) < 0 THEN
            GREATEST(:minimum_points, LEAST(:burst, rate_limits.points + :rate * EXTRACT(epoch FROM (:now - rate_limits.updated_at))) - :rate)
          ELSE
            GREATEST(:minimum_points, LEAST(:burst, rate_limits.points + :rate * EXTRACT(epoch FROM (:now - rate_limits.updated_at))) - :cost)
          END
      RETURNING *
    SQL

    points = [burst - cost, minimum_points].max

    sql_params = {
      now: Time.zone.now,
      action: action,
      rate: rate,
      burst: burst,
      cost: cost,
      points: points,
      minimum_points: minimum_points,
      limited: points < 0,
      **key_params,
    }

    RateLimit.find_by_sql([sql, sql_params])
  end
end
