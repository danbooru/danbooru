class WikiPage < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  before_save :normalize_title
  before_create :initialize_creator
  after_save :create_version
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  validates_uniqueness_of :title, :case_sensitive => false
  validates_presence_of :body, :updater_id, :updater_ip_addr
  attr_accessible :title, :body, :updater_id, :updater_ip_addr
  scope :titled, lambda {|title| where(["title = ?", title.downcase.tr(" ", "_")])}
  has_one :tag, :foreign_key => "name", :primary_key => "title"
  has_one :artist, :foreign_key => "name", :primary_key => "title"
  has_many :versions, :class_name => "WikiPageVersion"
  
  def self.build_relation(options = {})
    relation = where()
    
    if options[:title]
      relation = relation.where(["title LIKE ? ESCAPE E'\\\\'", options[:title].downcase.tr(" ", "_").to_escaped_for_sql_like])
    end
    
    if options[:creator_id]
      relation = relation.where(["creator_id = ?", options[:creator_id]])
    end
    
    relation
  end
  
  def revert_to(version, reverter_id, reverter_ip_addr)
    self.title = version.title
    self.body = version.body
    self.is_locked = version.is_locked
    self.updater_id = reverter_id
    self.updater_ip_addr = reverter_ip_addr
  end
  
  def revert_to!(version, reverter_id, reverter_ip_addr)
    revert_to(version, reverter_id, reverter_ip_addr)
    save!
  end

  def normalize_title
    self.title = title.downcase.tr(" ", "_")
  end

  def creator_name
    User.id_to_name(user_id).tr("_", " ")
  end

  def pretty_title
    title.tr("_", " ")
  end
  
  def create_version
    if title_changed? || body_changed? || is_locked_changed?
      versions.create(
        :updater_id => updater_id,
        :updater_ip_addr => updater_ip_addr,
        :title => title,
        :body => body,
        :is_locked => is_locked
      )
    end
  end
  
  def initialize_creator
    if creator.nil?
      self.creator_id = updater_id
    end
  end
end
