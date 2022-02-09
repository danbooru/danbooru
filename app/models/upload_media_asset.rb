# frozen_string_literal: true

class UploadMediaAsset < ApplicationRecord
  belongs_to :upload
  belongs_to :media_asset

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :upload, :media_asset)
    q.apply_default_order(params)
  end
end
