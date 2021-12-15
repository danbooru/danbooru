# frozen_string_literal: true

# A job that runs daily to remove old post disapprovals. Spawned by
# {DanbooruMaintenance}.
class PrunePostDisapprovalsJob < ApplicationJob
  def perform
    PostDisapproval.prune!
  end
end
