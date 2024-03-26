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

  scope :unfinished, -> { where(status: %w[pending processing]) }
  scope :finished, -> { where(status: %w[active failed]) }
  scope :expired, -> { unfinished.where(created_at: ..4.hours.ago) }

  def self.visible(user)
    if user.is_admin?
      all
    elsif user.is_anonymous?
      none
    else
      where(upload: user.uploads)
    end
  end

  def self.prune!
    expired.update_all(status: :failed, error: "Stuck processing for more than 4 hours")
  end

  def self.is_matches(value)
    case value.downcase
    when *UploadMediaAsset.statuses.keys
      where(status: value)
    when *MediaAsset::FILE_TYPES
      attribute_matches(value, :file_ext, :enum)
    else
      none
    end
  end

  def self.exif_matches(string)
    merge(MediaAsset.exif_matches(string))
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :status, :source_url, :page_url, :error, :upload, :media_asset, :post], current_user: current_user)

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
    # XXX in production there are ~150 old assets with blank source urls because the source went bad id before the image url could be saved.
    source_url.starts_with?("file://") || source_url.blank?
  end

  def bad_source?
    parsed_canonical_url&.recognized? && parsed_canonical_url&.image_url? && parsed_canonical_url&.page_url.nil?
  end

  def image_sample?
    parsed_canonical_url&.recognized? && parsed_canonical_url&.image_sample?
  end

  # The source of the post after upload. This is either the image URL, if the image URL is convertible to a page URL
  # (e.g. Pixiv), or the page URL if it's not (e.g. Twitter).
  memoize def canonical_url
    if file_upload?
      source_url

    # If the source is an image URL that is convertible to a page URL, then use the image URL as the post source.
    elsif Source::URL.page_url(source_url).present?
      source_url

    # If a better page URL can be found by the extractor (potentially with an API call), then use that as the source.
    elsif source_extractor&.page_url.present?
      source_extractor.page_url

    # If we can't find any better page URL, then just use the one we already have.
    elsif page_url.present?
      page_url

    # Otherwise if we can't find a page URL at all, then just use the image URL.
    else
      source_url
    end
  end

  memoize def parsed_canonical_url
    Source::URL.parse(canonical_url) unless file_upload?
  end

  def source_extractor
    return nil if source_url.blank?
    Source::Extractor.find(source_url, page_url)
  end

  # Calls `process_upload!`
  def async_process_upload!
    if file.present?
      ProcessUploadMediaAssetJob.perform_now(self)
    else
      ProcessUploadMediaAssetJob.perform_later(self)
    end
  end

  def process_upload!
    update!(status: :processing)

    if file.present?
      media_file = MediaFile.open(file)
    else
      media_file = source_extractor.download_file!(source_url)
    end

    MediaAsset.validate_media_file!(media_file, upload.uploader)
    MediaAsset.upload!(media_file) do |media_asset|
      update!(media_asset: media_asset)
    end

    update!(status: :active)
  rescue Exception => e
    update!(status: :failed, error: e.message)
  ensure
    media_file&.close
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

  memoize :source_extractor
end
