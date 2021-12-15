# frozen_string_literal: true

# A job that runs monthly to demote all inactive approvers. Spawned by
# {DanbooruMaintenance}.
class PruneApproversJob < ApplicationJob
  def perform
    ApproverPruner.prune!
  end
end
