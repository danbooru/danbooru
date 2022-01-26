# frozen_string_literal: true

class Upload < ApplicationRecord
  MAX_VIDEO_DURATION = 140

  attr_accessor :file

  belongs_to :uploader, class_name: "User"
  has_many :upload_media_assets, dependent: :destroy
  has_many :media_assets, through: :upload_media_assets

  validates :source, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { source.present? }
  validates :referer_url, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { referer_url.present? }

  after_create :async_process_upload!

  scope :pending, -> { where(status: "pending") }
  scope :preprocessed, -> { where(status: "preprocessed") }
  scope :completed, -> { where(status: "completed") }

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
      status.match?(/error:/)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :source, :referer_url, :uploader, :status, :backtrace, :upload_media_assets, :media_assets)
    q.apply_default_order(params)
  end

  def async_process_upload!
    if file.present?
      ProcessUploadJob.perform_now(self)
    else
      ProcessUploadJob.perform_later(self)
    end
  end

  def process_upload!
    update!(status: "processing")

    if file.present?
      media_file = MediaFile.open(file.tempfile)
    elsif source.present?
      strategy = Sources::Strategies.find(source, referer_url)
      media_file = strategy.download_file!(strategy.image_url)
    else
      raise "No file or source provided"
    end

    media_asset = MediaAsset.upload!(media_file)
    update!(media_assets: [media_asset], status: "completed")
  rescue Exception => e
    update!(status: "error: #{e.message}", backtrace: e.backtrace.join("\n"))
    raise
  end

  def self.available_includes
    [:uploader, :upload_media_assets, :media_assets]
  end
end
