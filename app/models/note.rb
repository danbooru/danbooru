class Note < ApplicationRecord
  class RevertError < Exception ; end

  attr_accessor :updater_id, :updater_ip_addr, :html_id
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :versions, lambda {order("note_versions.id ASC")}, :class_name => "NoteVersion", :dependent => :destroy
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  validates_presence_of :post_id, :creator_id, :updater_id, :x, :y, :width, :height, :body
  validate :post_must_exist
  validate :note_within_image
  after_save :update_post
  after_save :create_version
  validate :post_must_not_be_note_locked

  module SearchMethods
    def active
      where("is_active = TRUE")
    end

    def body_matches(query)
      if query =~ /\*/ && CurrentUser.user.is_builder?
        where("body ILIKE ? ESCAPE E'\\\\'", query.to_escaped_for_sql_like)
      else
        where("body_index @@ plainto_tsquery(E?)", query.to_escaped_for_tsquery_split)
      end
    end

    def post_tags_match(query)
      PostQueryBuilder.new(query).build(self.joins(:post)).reorder("")
    end

    def for_creator(user_id)
      where("creator_id = ?", user_id)
    end

    def creator_name(name)
      where("creator_id = (select _.id from users _ where lower(_.name) = ?)", name.mb_chars.downcase)
    end

    def search(params)
      q = super

      if params[:body_matches].present?
        q = q.body_matches(params[:body_matches])
      end

      if params[:is_active] == "true"
        q = q.active
      elsif params[:is_active] == "false"
        q = q.where("is_active = false")
      end

      if params[:post_id].present?
        q = q.where(post_id: params[:post_id].split(",").map(&:to_i))
      end

      if params[:post_tags_match].present?
        q = q.post_tags_match(params[:post_tags_match])
      end

      if params[:creator_name].present?
        q = q.creator_name(params[:creator_name].tr(" ", "_"))
      end

      if params[:creator_id].present?
        q = q.where(creator_id: params[:creator_id].split(",").map(&:to_i))
      end

      q.apply_default_order(params)
    end
  end

  module ApiMethods
    def hidden_attributes
      super + [:body_index]
    end

    def method_attributes
      super + [:creator_name]
    end
  end

  extend SearchMethods
  include ApiMethods

  def initialize_creator
    self.creator_id ||= CurrentUser.id
  end

  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end

  def post_must_exist
    if !Post.exists?(post_id)
      errors.add :post, "must exist"
      return false
    end
  end

  def post_must_not_be_note_locked
    if is_locked?
      errors.add :post, "is note locked"
      return false
    end
  end

  def note_within_image
    return false unless post.present?
    if x < 0 || y < 0 || (x > post.image_width) || (y > post.image_height) || width < 0 || height < 0 || (x + width > post.image_width) || (y + height > post.image_height)
      self.errors.add(:note, "must be inside the image")
      return false
    end
  end

  def is_locked?
    Post.exists?(["id = ? AND is_note_locked = ?", post_id, true])
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def rescale!(x_scale, y_scale)
    self.x *= x_scale
    self.y *= y_scale
    self.width *= x_scale
    self.height *= y_scale
    save!
  end

  def update_post
    if self.changed?
      if Note.where(:is_active => true, :post_id => post_id).exists?
        execute_sql("UPDATE posts SET last_noted_at = ? WHERE id = ?", updated_at, post_id)
      else
        execute_sql("UPDATE posts SET last_noted_at = NULL WHERE id = ?", post_id)
      end
    end
  end

  def create_version
    return unless versioned_attributes_changed?

    if merge_version?
      merge_version
    else
      Note.where(:id => id).update_all("version = coalesce(version, 0) + 1")
      reload
      create_new_version
    end
  end

  def versioned_attributes_changed?
    new_record? || x_changed? || y_changed? || width_changed? || height_changed? || is_active_changed? || body_changed?
  end

  def create_new_version
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
    prev.update_attributes(
      :x => x,
      :y => y,
      :width => width,
      :height => height,
      :is_active => is_active,
      :body => body
    )
  end

  def merge_version?
    prev = versions.last
    prev && prev.updater_id == CurrentUser.user.id && prev.updated_at > 1.hour.ago && !is_active_changed?
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
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
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
end
