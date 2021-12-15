# frozen_string_literal: true

# A job that runs weekly to warn inactive approvers before they're demoted.
# Spawned by {DanbooruMaintenance}.
class DmailInactiveApproversJob < ApplicationJob
  def perform
    ApproverPruner.dmail_inactive_approvers!
  end
end
