# frozen_string_literal: true

class Upload < ApplicationRecord
  extend Memoist
  class Error < StandardError; end

  attr_accessor :file

  belongs_to :uploader, class_name: "User"
  has_many :upload_media_assets, dependent: :destroy
  has_many :media_assets, through: :upload_media_assets
  has_many :posts, through: :media_assets

  normalize :source, :normalize_source

  validates :source, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { source.present? }
  validates :referer_url, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { referer_url.present? }
  validate :validate_file_and_source, on: :create

  after_create :async_process_upload!

  scope :pending, -> { where(status: "pending") }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "error") }

  def self.visible(user)
    if user.is_admin?
      all
    else
      where(uploader: user)
    end
  end

  concerning :StatusMethods do
    def is_pending?
      status == "pending"
    end

    def is_processing?
      status == "processing"
    end

    def is_completed?
      status == "completed"
    end

    def is_errored?
      status == "error"
    end

    def is_finished?
      is_completed? || is_errored?
    end
  end

  concerning :ValidationMethods do
    def validate_file_and_source
      if file.present? && source.present?
        errors.add(:base, "Can't give both a file and a source")
      elsif file.blank? && source.blank?
        errors.add(:base, "No file or source given")
      end
    end
  end

  concerning :SourceMethods do
    class_methods do
      # percent-encode unicode characters in the URL
      def normalize_source(url)
        return nil if url.nil?
        Addressable::URI.normalized_encode(url)
      end
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :source, :referer_url, :status, :media_asset_count, :uploader, :upload_media_assets, :media_assets, :posts)

    if params[:is_posted].to_s.truthy?
      q = q.where.not(id: Upload.where.missing(:posts))
    elsif params[:is_posted].to_s.falsy?
      q = q.where(id: Upload.where.missing(:posts))
    end

    q.apply_default_order(params)
  end

  def async_process_upload!
    if file.present?
      ProcessUploadJob.perform_now(self)
    elsif source.present?
      ProcessUploadJob.perform_later(self)
    else
      raise "No file or source given" # Should never happen
    end
  end

  def process_upload!
    update!(status: "processing")

    if file.present?
      media_file = MediaFile.open(file.tempfile)
      media_asset = MediaAsset.upload!(media_file)
      upload_media_asset = UploadMediaAsset.new(media_asset: media_asset, source_url: "file://#{file.original_filename}", status: "active")

      update!(upload_media_assets: [upload_media_asset], status: "completed", media_asset_count: 1)
    elsif source.present?
      page_url = source_strategy.page_url
      image_urls = source_strategy.image_urls

      if image_urls.empty?
        raise Error, "#{source} doesn't contain any images"
      end

      upload_media_assets = image_urls.map do |image_url|
        UploadMediaAsset.new(source_url: image_url, page_url: page_url, media_asset: nil)
      end

      update!(upload_media_assets: upload_media_assets, media_asset_count: upload_media_assets.size)
    else
      raise Error, "No file or source given" # Should never happen
    end
  rescue Exception => e
    update!(status: "error", error: e.message)
  end

  def source_strategy
    return nil if source.blank?
    Sources::Strategies.find(source, referer_url)
  end

  def self.available_includes
    [:uploader, :upload_media_assets, :media_assets, :posts]
  end

  memoize :source_strategy
end
