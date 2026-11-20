# frozen_string_literal: true

# A job that runs daily to purge the personal info of old DMCA requests. Spawned by {DanbooruMaintenance}.
class PruneDmcaRequestsJob < ApplicationJob
  def perform
    DmcaRequest.prune!
  end
end
