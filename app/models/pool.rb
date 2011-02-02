class Pool < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :versions, :class_name => "PoolVersion", :dependent => :destroy, :order => "pool_versions.id ASC"
  before_validation :normalize_name
  before_validation :initialize_creator, :on => :create
  after_save :create_version
  attr_accessible :name, :description, :post_ids, :is_active
  
  def self.name_to_id(name)
    select_value_sql("SELECT id FROM pools WHERE name = ?", name.downcase)
  end
  
  def self.create_anonymous(creator, creator_ip_addr)
    Pool.new do |pool|
      pool.name = "TEMP:#{Time.now.to_f}.#{rand(1_000_000)}"
      pool.creator = creator
      pool.save
      pool.name = "anonymous:#{pool.id}"
      pool.save
    end
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def normalize_name
    self.name = name.downcase
  end
  
  def revert_to!(version)
    self.post_ids = version.post_ids
    save
  end
  
  def add_post!(post)
    return if post_ids =~ /(?:\A| )#{post.id}(?:\Z| )/
    
    self.post_ids += " #{post.id}"
    self.post_ids = post_ids.strip
    save
  end
  
  def remove_post!(post)
    self.post_ids = post_ids.gsub(/(?:\A| )#{post.id}(?:\Z| )/, " ")
    self.post_ids = post_ids.strip
    save
  end
  
  def posts(options = {})
    offset = options[:offset] || 0
    limit = options[:limit] || 20
    ids = post_id_array[offset, limit]
    Post.where(["id IN (?)", ids])
  end
  
  def post_id_array
    @post_id_array ||= post_ids.scan(/\d+/).map(&:to_i)
  end
  
  def clear_post_id_array
    @post_id_array = nil
  end
  
  def neighbor_posts(post)
    post_ids =~ /\A#{post.id} (\d+)|(\d+) #{post.id} (\d+)|(\d+) #{post.id}\Z/
    
    if $2 && $3
      {:previous => $2.to_i, :next => $3.to_i}
    elsif $1
      {:next => $1.to_i}
    elsif $4
      {:previous => $4.to_i}
    else
      nil
    end
  end
  
  def create_version
    last_version = versions.last

    if last_version && CurrentUser.ip_addr == last_version.updater_ip_addr && CurrentUser.id == last_version.updater_id
      last_version.update_attribute(:post_ids, post_ids)
    else
      versions.create(:post_ids => post_ids)
    end
  end
  
  def reload(options = {})
    super
    clear_post_id_array
  end
end
