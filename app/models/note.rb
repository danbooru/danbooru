class Note < ApplicationRecord
  class RevertError < StandardError; end

  attr_accessor :html_id
  belongs_to :post
  belongs_to :creator, class_name: "User"
  has_many :versions, -> {order("note_versions.id ASC")}, :class_name => "NoteVersion", :dependent => :destroy
  validates_presence_of :x, :y, :width, :height, :body
  validate :note_within_image
  after_save :update_post
  after_save :create_version
  validate :post_must_not_be_note_locked

  api_attributes including: [:creator_name]

  module SearchMethods
    def active
      where("is_active = TRUE")
    end

    def search(params)
      q = super

      q = q.search_attributes(params, :creator, :post, :is_active, :x, :y, :width, :height, :body, :version)
      q = q.text_attribute_matches(:body, params[:body_matches], index_column: :body_index)

      q.apply_default_order(params)
    end
  end

  def creator_name
    creator.name
  end

  extend SearchMethods

  def post_must_not_be_note_locked
    if is_locked?
      errors.add :post, "is note locked"
    end
  end

  def note_within_image
    return false unless post.present?
    if x < 0 || y < 0 || (x > post.image_width) || (y > post.image_height) || width < 0 || height < 0 || (x + width > post.image_width) || (y + height > post.image_height)
      self.errors.add(:note, "must be inside the image")
    end
  end

  def is_locked?
    Post.exists?(["id = ? AND is_note_locked = ?", post_id, true])
  end

  def rescale!(x_scale, y_scale)
    self.x *= x_scale
    self.y *= y_scale
    self.width *= x_scale
    self.height *= y_scale
    save!
  end

  def update_post
    if self.saved_changes?
      if Note.where(:is_active => true, :post_id => post_id).exists?
        execute_sql("UPDATE posts SET last_noted_at = ? WHERE id = ?", updated_at, post_id)
      else
        execute_sql("UPDATE posts SET last_noted_at = NULL WHERE id = ?", post_id)
      end
    end
  end

  def create_version(updater: CurrentUser.user, updater_ip_addr: CurrentUser.ip_addr)
    return unless saved_change_to_versioned_attributes?

    if merge_version?(updater.id)
      merge_version
    else
      Note.where(:id => id).update_all("version = coalesce(version, 0) + 1")
      reload
      create_new_version(updater.id, updater_ip_addr)
    end
  end

  def saved_change_to_versioned_attributes?
    new_record? || saved_change_to_x? || saved_change_to_y? || saved_change_to_width? || saved_change_to_height? || saved_change_to_is_active? || saved_change_to_body?
  end

  def create_new_version(updater_id, updater_ip_addr)
    versions.create(
      :updater_id => updater_id,
      :updater_ip_addr => updater_ip_addr,
      :post_id => post_id,
      :x => x,
      :y => y,
      :width => width,
      :height => height,
      :is_active => is_active,
      :body => body,
      :version => version
    )
  end

  def merge_version
    prev = versions.last
    prev.update(x: x, y: y, width: width, height: height, is_active: is_active, body: body)
  end

  def merge_version?(updater_id)
    prev = versions.last
    prev && prev.updater_id == updater_id && prev.updated_at > 1.hour.ago && !saved_change_to_is_active?
  end

  def revert_to(version)
    if id != version.note_id
      raise RevertError.new("You cannot revert to a previous version of another note.")
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

  def copy_to(new_post, creator: CurrentUser.user)
    new_note = dup
    new_note.creator = creator
    new_note.post_id = new_post.id
    new_note.version = 0

    width_ratio = new_post.image_width.to_f / post.image_width
    height_ratio = new_post.image_height.to_f / post.image_height
    new_note.x = x * width_ratio
    new_note.y = y * height_ratio
    new_note.width = width * width_ratio
    new_note.height = height * height_ratio

    new_note.save
  end

  def self.undo_changes_by_user(vandal_id)
    transaction do
      note_ids = NoteVersion.where(:updater_id => vandal_id).select("note_id").distinct.map(&:note_id)
      NoteVersion.where(["updater_id = ?", vandal_id]).delete_all
      note_ids.each do |note_id|
        note = Note.find(note_id)
        most_recent = note.versions.last
        if most_recent
          note.revert_to!(most_recent)
        end
      end
    end
  end

  def self.available_includes
    [:creator, :post]
  end
end
