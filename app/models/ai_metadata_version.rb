# frozen_string_literal: true

class AIMetadataVersion < ApplicationRecord
  include VersionFor

  belongs_to :post
  belongs_to_updater
  version_for :ai_metadata

  alias previous previous_version

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :post_id, :prompt, :negative_prompt, :parameters, :created_at, :updated_at, :version, :updater_id], current_user: current_user)

    q.apply_default_order(params)
  end

  def self.status_fields
    {
      prompt: "Prompt",
      negative_prompt: "NegPrompt",
      parameters: "Parameters",
    }
  end

  def sorted_parameters
    parameters.sort do |first, second|
      [AIMetadata::PARAMETER_ORDER.index(first[0]) || AIMetadata::PARAMETER_ORDER.length + 1, first[0]] <=>
        [AIMetadata::PARAMETER_ORDER.index(second[0]) || AIMetadata::PARAMETER_ORDER.length + 1, second[0]]
    end
  end

  def self.available_includes
    [:post, :updater, :ai_metadata]
  end
end
