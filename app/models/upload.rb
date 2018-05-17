require "tmpdir"

class Upload < ApplicationRecord
  class Error < Exception ; end

  class Validator < ActiveModel::Validator
    def validate(record)
      if record.new_record?
        validate_md5_uniqueness(record)
        validate_video_duration(record)
      end

      validate_resolution(record)
    end

    def validate_md5_uniqueness(record)
      if record.md5.nil?
        return
      end

      md5_post = Post.find_by_md5(record.md5)

      if md5_post.nil?
        return
      end

      if record.replaced_post && record.replaced_post == md5_post
        return
      end

      record.errors[:md5] << "duplicate: #{md5_post.id}"
    end

    def validate_resolution(record)
      resolution = record.image_width.to_i * record.image_height.to_i

      if resolution > Danbooru.config.max_image_resolution
        record.errors[:base] << "image resolution is too large (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{record.image_width}x#{record.image_height}); max: #{Danbooru.config.max_image_resolution / 1_000_000} megapixels)"
      end
    end

    def validate_video_duration(record)
      if record.is_video? && record.video.duration > 120
        record.errors[:base] << "video must not be longer than 2 minutes"
      end
    end
  end


  attr_accessor :as_pending,
    :referer_url, :downloaded_source, :replaced_post, :file
  belongs_to :uploader, :class_name => "User"
  belongs_to :post, optional: true

  before_validation :initialize_attributes
  before_validation :assign_rating_from_tags
  validate :uploader_is_not_limited, on: :create
  # validates :source, format: { with: /\Ahttps?/ }, if: ->(record) {record.file.blank?}, on: :create
  validates :image_height, numericality: { less_than_or_equal_to: Danbooru.config.max_image_height }, allow_nil: true
  validates :image_width, numericality: { less_than_or_equal_to: Danbooru.config.max_image_width }, allow_nil: true
  validates :rating, inclusion: { in: %w(q e s) }, allow_nil: true
  validates :md5, confirmation: true
  validates :file_ext, format: { with: /jpg|gif|png|swf|webm|mp4|zip/ }, allow_nil: true
  validates_with Validator
  serialize :context, JSON
  after_create {|rec| rec.uploader.increment!(:post_upload_count)}

  def initialize_attributes
    self.uploader_id = CurrentUser.user.id
    self.uploader_ip_addr = CurrentUser.ip_addr
    self.server = Danbooru.config.server_host
  end

  module FileMethods
    def is_image?
      %w(jpg gif png).include?(file_ext)
    end

    def is_flash?
      %w(swf).include?(file_ext)
    end

    def is_video?
      %w(webm mp4).include?(file_ext)
    end

    def is_ugoira?
      %w(zip).include?(file_ext)
    end
  end

  module StatusMethods
    def is_pending?
      status == "pending"
    end

    def is_processing?
      status == "processing"
    end

    def is_completed?
      status == "completed"
    end

    def is_preprocessed?
      status == "preprocessed"
    end

    def is_preprocessing?
      status == "preprocessing"
    end

    def is_duplicate?
      status =~ /duplicate/
    end

    def duplicate_post_id
      @duplicate_post_id ||= status[/duplicate: (\d+)/, 1]
    end
  end

  module UploaderMethods
    def uploader_name
      User.id_to_name(uploader_id)
    end
  end

  module VideoMethods
    def video
      @video ||= FFMPEG::Movie.new(file.path)
    end
  end

  module SearchMethods
    def uploaded_by(user_id)
      where("uploader_id = ?", user_id)
    end

    def pending
      where(:status => "pending")
    end

    def post_tags_match(query)
      PostQueryBuilder.new(query).build(self.joins(:post)).reorder("")
    end

    def search(params)
      q = super

      if params[:uploader_id].present?
        q = q.attribute_matches(:uploader_id, params[:uploader_id])
      end

      if params[:uploader_name].present?
        q = q.where(uploader_id: User.name_to_id(params[:uploader_name]))
      end

      if params[:source].present?
        q = q.where(source: params[:source])
      end

      if params[:source_matches].present?
        q = q.where("uploads.source LIKE ? ESCAPE E'\\\\'", params[:source_matches].to_escaped_for_sql_like)
      end

      if params[:rating].present?
        q = q.where(rating: params[:rating])
      end

      if params[:parent_id].present?
        q = q.attribute_matches(:rating, params[:parent_id])
      end

      if params[:post_id].present?
        q = q.attribute_matches(:post_id, params[:post_id])
      end

      if params[:has_post].to_s.truthy?
        q = q.where.not(post_id: nil)
      elsif params[:has_post].to_s.falsy?
        q = q.where(post_id: nil)
      end

      if params[:post_tags_match].present?
        q = q.post_tags_match(params[:post_tags_match])
      end

      if params[:status].present?
        q = q.where("uploads.status LIKE ? ESCAPE E'\\\\'", params[:status].to_escaped_for_sql_like)
      end

      if params[:backtrace].present?
        q = q.where("uploads.backtrace LIKE ? ESCAPE E'\\\\'", params[:backtrace].to_escaped_for_sql_like)
      end

      if params[:tag_string].present?
        q = q.where("uploads.tag_string LIKE ? ESCAPE E'\\\\'", params[:tag_string].to_escaped_for_sql_like)
      end

      if params[:server].present?
        q = q.where(server: params[:server])
      end

      q.apply_default_order(params)
    end
  end

  module ApiMethods
    def method_attributes
      super + [:uploader_name]
    end
  end

  include FileMethods
  include StatusMethods
  include UploaderMethods
  include VideoMethods
  extend SearchMethods
  include ApiMethods

  def uploader_is_not_limited
    if !uploader.can_upload?
      self.errors.add(:uploader, uploader.upload_limited_reason)
      return false
    else
      return true
    end
  end

  def assign_rating_from_tags
    if tag_string =~ /(?:\s|^)rating:([qse])/i
      self.rating = $1.downcase
    end
  end

  def presenter
    @presenter ||= UploadPresenter.new(self)
  end

  def upload_as_pending?
    as_pending.to_s.truthy?
  end
end
