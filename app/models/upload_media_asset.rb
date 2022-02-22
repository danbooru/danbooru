# frozen_string_literal: true

class UploadMediaAsset < ApplicationRecord
  extend Memoist

  attr_accessor :file

  belongs_to :upload
  belongs_to :media_asset, optional: true
  has_one :post, through: :media_asset

  after_create :async_process_upload!
  after_save :update_upload_status, if: :saved_change_to_status?

  # XXX there are ~150 old assets with blank source urls because the source went bad id before the image url could be saved.
  validates :source_url, format: { with: %r{\A(https?|file)://}i, message: "is not a valid URL" }
  validates :page_url, format: { with: %r{\A(https?)://}i, message: "is not a valid URL" }, allow_nil: true

  enum status: {
    pending: 0,
    processing: 100,
    active: 200,
    failed: 300,
  }

  def self.visible(user)
    if user.is_admin?
      all
    else
      where(upload: { uploader: user })
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :status, :source_url, :page_url, :error, :upload, :media_asset, :post)

    if params[:is_posted].to_s.truthy?
      q = q.where.associated(:post)
    elsif params[:is_posted].to_s.falsy?
      q = q.where.missing(:post)
    end

    case params[:order]
    when "id_desc"
      q = q.order(id: :desc)
    when "id_asc"
      q = q.order(id: :asc)
    else
      q.apply_default_order(params)
    end
  end

  def loading?
    pending? || processing?
  end

  def finished?
    active? || failed?
  end

  def file_upload?
    source_url.starts_with?("file://")
  end

  def source_strategy
    return nil if source_url.blank?
    Sources::Strategies.find(source_url, page_url)
  end

  def async_process_upload!
    if file.present?
      process_upload!
    else
      ProcessUploadMediaAssetJob.perform_later(self)
    end
  end

  def process_upload!
    update!(status: :processing)

    if file.present?
      media_file = MediaFile.open(file)
    else
      media_file = source_strategy.download_file!(source_url)
    end

    MediaAsset.upload!(media_file) do |media_asset|
      update!(media_asset: media_asset)
    end

    update!(status: :active)
  rescue Exception => e
    update!(status: :failed, error: e.message)
  end

  def update_upload_status
    upload.with_lock do
      if upload.upload_media_assets.all?(&:failed?)
        upload.update!(status: "error", error: upload.upload_media_assets.map(&:error).join("; "))
      elsif upload.upload_media_assets.all?(&:finished?)
        upload.update!(status: "completed")
      end
    end
  end

  memoize :source_strategy
end
