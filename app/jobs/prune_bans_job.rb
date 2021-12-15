# frozen_string_literal: true

# A job that runs daily to remove expired bans. Spawned by
# {DanbooruMaintenance}.
class PruneBansJob < ApplicationJob
  def perform
    Ban.prune!
  end
end
