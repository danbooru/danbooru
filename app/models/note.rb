class Note < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  belongs_to :post
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  before_save :initialize_creator
  before_save :blank_body
  has_many :versions, :class_name => "NoteVersion"
  after_save :update_post
  after_save :create_version
  validate :post_must_not_be_note_locked
  validates_presence_of :updater_id, :updater_ip_addr
  attr_accessible :x, :y, :width, :height, :body, :updater_id, :updater_ip_addr, :is_active
  scope :active, where("is_active = TRUE")
  
  def presenter
    @presenter ||= NotePresenter.new(self)
  end
  
  def initialize_creator
    self.creator_id = updater_id
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
    User.find_name(creator_id)
  end

  def update_post
    if Note.exists?(["is_active = ? AND post_id = ?", true, post_id])
      Post.update(post_id, :last_noted_at => updated_at, :updater_id => updater_id, :updater_ip_addr => updater_ip_addr)
    else
      Post.update(post_id, :last_noted_at => nil, :updater_id => updater_id, :updater_ip_addr => updater_ip_addr)
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
  
  def revert_to(version, reverter_id, reverter_ip_addr)
    self.x = version.x
    self.y = version.y
    self.body = version.body
    self.width = version.width
    self.height = version.height
    self.is_active = version.is_active
    self.updater_id = reverter_id
    self.updater_ip_addr = reverter_ip_addr
  end
  
  def revert_to!(version, reverter_id, reverter_ip_addr)
    revert_to(version, reverter_id, reverter_ip_addr)
    save!
  end

  def self.undo_changes_by_user(user_id, reverter_id, reverter_ip_addr)
    transaction do
      notes = Note.joins(:versions).where(["note_versions.updater_id = ?", user_id]).select("DISTINCT notes.*").all
      NoteVersion.destroy_all(["updater_id = ?", user_id])
      notes.each do |note|
        first = note.versions.first
        if first
          note.revert_to!(first, reverter_id, reverter_ip_addr)
        end
      end
    end
  end
  
  def self.build_relation(params)
    relation = where()
    
    if !params[:query].blank?
      query = params[:query].scan(/\S+/).join(" & ")        
      relation = relation.where(["text_index @@ plainto_tsquery(?)", query])
    end
    
    if params[:status] == "Active"
      relation = relation.where("is_active = TRUE")
    elsif params[:status] == "Deleted"
      relation = relation.where("is_active = FALSE")
    end

    relation
  end
end
