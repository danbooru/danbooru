# frozen_string_literal: true

class PruneApiKeysJob < ApplicationJob
  def perform
    ApiKey.prune!
  end
end
