# frozen_string_literal: true

class UploadMediaAsset < ApplicationRecord
  belongs_to :upload, counter_cache: :media_asset_count
  belongs_to :media_asset, optional: true

  after_create :async_process_upload!
  after_save :update_upload_status, if: :saved_change_to_status?

  enum status: {
    pending: 0,
    processing: 100,
    active: 200,
    failed: 300,
  }

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :status, :source_url, :page_url, :error, :upload, :media_asset)
    q.apply_default_order(params)
  end

  def finished?
    active? || failed?
  end

  def async_process_upload!
    ProcessUploadMediaAssetJob.perform_later(self)
  end

  def process_upload!
    update!(status: :processing)

    strategy = Sources::Strategies.find(source_url)
    media_file = strategy.download_file!(source_url)
    MediaAsset.upload!(media_file) do |media_asset|
      update!(media_asset: media_asset)
    end

    update!(status: :active)
  rescue Exception => e
    update!(status: :failed, error: e.message)
  end

  def update_upload_status
    upload.with_lock do
      upload.update!(status: "completed") if upload.upload_media_assets.all?(&:finished?)
    end
  end
end
