class Note < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_updater
  before_validation :blank_body
  validates_presence_of :post_id, :creator_id, :updater_id
  has_many :versions, :class_name => "NoteVersion", :order => "note_versions.id ASC"
  after_save :update_post
  after_save :create_version
  validate :post_must_not_be_note_locked
  attr_accessible :x, :y, :width, :height, :body, :updater_id, :updater_ip_addr, :is_active, :post_id
  scope :active, where("is_active = TRUE")
  scope :body_matches, lambda {|query| where("text_index @@ plainto_tsquery(?)", query.scan(/\S+/).join(" & "))}
  search_method :body_matches
  
  def presenter
    @presenter ||= NotePresenter.new(self)
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def initialize_updater
    self.updater_id = CurrentUser.id
    self.updater_ip_addr = CurrentUser.ip_addr
  end
  
  def post_must_not_be_note_locked
    if is_locked?
      errors.add :post, "is note locked"
      return false
    end
  end
  
  def is_locked?
    Post.exists?(["id = ? AND is_note_locked = ?", post_id, true])
  end
  
  def blank_body
    self.body = "(empty)" if body.blank?
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def update_post
    if Note.exists?(["is_active = ? AND post_id = ?", true, post_id])
      execute_sql("UPDATE posts SET last_noted_at = ? WHERE id = ?", updated_at, post_id)
    else
      execute_sql("UPDATE posts SET last_noted_at = NULL WHERE id = ?", post_id)
    end
  end
  
  def create_version
    versions.create(
      :updater_id => updater_id,
      :updater_ip_addr => updater_ip_addr,
      :x => x,
      :y => y,
      :width => width,
      :height => height,
      :is_active => is_active,
      :body => body
    )
  end
  
  def revert_to(version)
    self.x = version.x
    self.y = version.y
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

  def self.undo_changes_by_user(user_id)
    transaction do
      notes = Note.joins(:versions).where(["note_versions.updater_id = ?", user_id]).select("DISTINCT notes.*").all
      NoteVersion.destroy_all(["updater_id = ?", user_id])
      notes.each do |note|
        first = note.versions.first
        if first
          note.revert_to!(first)
        end
      end
    end
  end
end
