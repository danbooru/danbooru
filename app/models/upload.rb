# frozen_string_literal: true

class Upload < ApplicationRecord
  extend Memoist

  self.ignored_columns = %i[
    file_path content_type rating tag_string backtrace post_id md5_confirmation
    server parent_id md5 file_ext file_size image_width image_height
    artist_commentary_desc artist_commentary_title include_artist_commentary
    context translated_commentary_title translated_commentary_desc
  ]

  attr_accessor :file

  belongs_to :uploader, class_name: "User"
  has_many :upload_media_assets, dependent: :destroy
  has_many :media_assets, through: :upload_media_assets

  normalize :source, :normalize_source

  validates :source, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { source.present? }
  validates :referer_url, format: { with: %r{\Ahttps?://}i, message: "is not a valid URL" }, if: -> { referer_url.present? }
  validate :validate_file_and_source, on: :create

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

    def source_strategy
      return nil if source.blank?
      Sources::Strategies.find(source, referer_url)
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :source, :referer_url, :status, :uploader, :upload_media_assets, :media_assets)
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
    elsif source.present?
      strategy = Sources::Strategies.find(source, referer_url)
      media_file = strategy.download_file!(strategy.image_url)
    else
      raise "No file or source given" # Should never happen
    end

    media_asset = MediaAsset.upload!(media_file)
    update!(media_assets: [media_asset], status: "completed")
  rescue Exception => e
    update!(status: "error: #{e.message}")
  end

  def self.available_includes
    [:uploader, :upload_media_assets, :media_assets]
  end

  memoize :source_strategy
end
