# frozen_string_literal: true

# A job that runs weekly to retire inactive aliases and implications. Spawned
# by {DanbooruMaintenance}.
class RetireTagRelationshipsJob < ApplicationJob
  def perform
    TagRelationshipRetirementService.find_and_retire!
  end
end
