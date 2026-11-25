# frozen_string_literal: true

class Note < ApplicationRecord
  class RevertError < StandardError; end

  MAX_NOTES_PER_POST = 1200
  MIN_NOTE_SIZE = 10

  attr_accessor :html_id

  belongs_to :post
  has_many :versions, -> { order("note_versions.id ASC") }, class_name: "NoteVersion", dependent: :destroy
  normalizes :body, with: ->(body) { body.to_s.unicode_normalize(:nfc).normalize_whitespace(eol: "\r\n").strip }

  validates :x, presence: true
  validates :y, presence: true
  validates :width, presence: true
  validates :height, presence: true
  validate :validate_note_size, if: -> { new_record? || width_changed? || height_changed? }
  validates :body, visible_string: true, length: { maximum: 5000 }, if: -> { new_record? || body_changed? }
  validate :validate_note_within_image
  validate :validate_post_can_have_notes, on: :create
  validate :validate_notes_per_post, if: -> { is_active? && (new_record? || is_active_changed?) }
  after_save :update_post
  after_save :create_version

  scope :active, -> { where(is_active: true) }

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, current_user: current_user)

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def validate_note_within_image
    return false unless post.present?
    if x < 0 || y < 0 || (x > post.image_width) || (y > post.image_height) || width < 0 || height < 0 || (x + width > post.image_width) || (y + height > post.image_height)
      errors.add(:note, "must be inside the image")
    end
  end

  # Notes must be at least 10x10, or the size of the whole image if the image is smaller than that.
  def validate_note_size
    min_width = [MIN_NOTE_SIZE, post&.image_width].compact.min
    min_height = [MIN_NOTE_SIZE, post&.image_height].compact.min

    errors.add(:width, "must be at least #{MIN_NOTE_SIZE} pixels") if width.present? && width < min_width
    errors.add(:height, "must be at least #{MIN_NOTE_SIZE} pixels") if height.present? && height < min_height
  end

  def validate_post_can_have_notes
    errors.add(:post, "cannot have notes") if post.present? && !post.can_have_notes?
  end

  def validate_notes_per_post
    return if post.blank?

    errors.add(:post, "can't have more than #{MAX_NOTES_PER_POST} notes") if post.notes.active.where.not(id: id).count >= MAX_NOTES_PER_POST
  end

  def rescale!(x_scale, y_scale)
    scale(x_scale, y_scale, post.image_width, post.image_height)
    save!
  end

  # Scale the note by the given ratios, keeping it at least the minimum size and inside an image of the given size.
  #
  # @param x_scale [Float] The horizontal scaling ratio.
  # @param y_scale [Float] The vertical scaling ratio.
  # @param image_width [Integer] The width of the image the note will be on.
  # @param image_height [Integer] The height of the image the note will be on.
  def scale(x_scale, y_scale, image_width, image_height)
    self.width = (width * x_scale).round.clamp([MIN_NOTE_SIZE, image_width].min, image_width)
    self.height = (height * y_scale).round.clamp([MIN_NOTE_SIZE, image_height].min, image_height)
    self.x = (x * x_scale).round.clamp(0, image_width - width)
    self.y = (y * y_scale).round.clamp(0, image_height - height)
  end

  def update_post
    if saved_changes?
      if post.notes.active.exists?
        post.update_columns(last_noted_at: updated_at)
      else
        post.update_columns(last_noted_at: nil)
      end
    end
  end

  def create_version(updater: CurrentUser.user)
    return unless saved_change_to_versioned_attributes?

    if merge_version?(updater.id)
      merge_version
    else
      Note.where(id: id).update_all("version = coalesce(version, 0) + 1")
      reload
      create_new_version(updater.id)
    end
  end

  def saved_change_to_versioned_attributes?
    new_record? || saved_change_to_x? || saved_change_to_y? || saved_change_to_width? || saved_change_to_height? || saved_change_to_is_active? || saved_change_to_body?
  end

  def create_new_version(updater_id)
    versions.create(
      updater_id: updater_id,
      post_id: post_id,
      x: x,
      y: y,
      width: width,
      height: height,
      is_active: is_active,
      body: body,
      version: version,
    )
  end

  def merge_version
    prev = versions.last
    prev.update(x: x, y: y, width: width, height: height, is_active: is_active, body: body)
  end

  def merge_version?(updater_id)
    prev = versions.last
    prev && prev.updater_id == updater_id && prev.updated_at > 1.hour.ago
  end

  def revert_to(version)
    if id != version.note_id
      raise RevertError, "You cannot revert to a previous version of another note."
    end

    self.x = version.x
    self.y = version.y
    self.post_id = version.post_id
    self.body = version.body
    self.width = version.width
    self.height = version.height
    self.is_active = version.is_active
  end

  def revert_to!(version)
    revert_to(version)
    save!
  end

  def copy_to(new_post)
    new_note = dup
    new_note.post_id = new_post.id
    new_note.version = 0

    width_ratio = new_post.image_width.to_f / post.image_width
    height_ratio = new_post.image_height.to_f / post.image_height
    new_note.scale(width_ratio, height_ratio, new_post.image_width, new_post.image_height)

    new_note.save
  end

  def sanitized_body
    NoteSanitizer.sanitize(body)
  end

  def self.available_includes
    [:post]
  end
end
