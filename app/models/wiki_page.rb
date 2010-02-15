class WikiPage < ActiveRecord::Base
  attr_accessor :updater_id, :updater_ip_addr
  before_save :normalize_title
  after_save :create_version
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  validates_uniqueness_of :title, :case_sensitive => false
  validates_presence_of :body, :updater_id, :updater_ip_addr
  attr_protected :text_search_index, :is_locked, :version
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
  
  def revert_to(version)
    self.title = version.title
    self.body = version.body
    self.is_locked = version.is_locked
  end
  
  def revert_to!(version)
    revert_to(version)
    save!
  end

  def normalize_title
    self.title = title.downcase.tr(" ", "_")
  end

  def creator_name
    User.find_name(user_id).tr("_", " ")
  end

  def pretty_title
    title.tr("_", " ")
  end
  
  def create_version
    versions.create(
      :updater_id => updater_id,
      :updater_ip_addr => updater_ip_addr,
      :title => title,
      :body => body,
      :is_locked => is_locked
    )
  end
end
