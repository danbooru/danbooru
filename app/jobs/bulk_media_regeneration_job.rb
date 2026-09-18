# frozen_string_literal: true

# A job that regenerates the metadata, files, and AI tags of all media assets matching a search query.
# Used to mass-fix media assets after a bug in file processing is fixed.
#
# @see BulkMediaRegenerationsController
class BulkMediaRegenerationJob < ApplicationJob
  def perform(query:)
    MediaAsset.active.ai_tags_match(query).parallel_find_each(order: :asc) do |media_asset|
      media_asset.regenerate!
    rescue StandardError => e
      DanbooruLogger.log(e, media_asset_id: media_asset.id)
    end
  end
end
