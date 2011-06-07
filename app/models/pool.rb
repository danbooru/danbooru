class Pool < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :versions, :class_name => "PoolVersion", :dependent => :destroy, :order => "pool_versions.id ASC"
  before_validation :normalize_name
  before_validation :normalize_post_ids
  before_validation :initialize_post_count
  before_validation :initialize_creator, :on => :create
  after_save :create_version
  after_save :balance_post_ids
  attr_accessible :name, :description, :post_ids, :is_active, :post_id_array
  
  def self.name_to_id(name)
    if name =~ /^\d+$/
      name.to_i
    else
      select_value_sql("SELECT id FROM pools WHERE name = ?", name.downcase)
    end
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
  
  def self.normalize_name(name)
    name.downcase.gsub(/\s+/, "_")
  end
  
  def self.normalize_post_ids(post_ids)
    post_ids.gsub(/\s{2,}/, " ").strip
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def normalize_name
    self.name = Pool.normalize_name(name)
  end
  
  def normalize_post_ids
    self.post_ids = Pool.normalize_post_ids(post_ids)
  end
  
  def revert_to!(version)
    self.post_ids = version.post_ids
    save
  end

  def contains_post?(post_id)
    post_ids =~ /(?:\A| )#{post_id}(?:\Z| )/
  end
  
  def add_post!(post)
    return if contains_post?(post.id)
    
    increment!(:post_count)
    update_attribute(:post_ids, "#{post_ids} #{post.id}".strip)
    post.add_pool!(self)
    clear_post_id_array
  end
  
  def remove_post!(post)
    return unless contains_post?(post.id)
    
    decrement!(:post_count)
    update_attribute(:post_ids, Pool.normalize_post_ids(post_ids.gsub(/(?:\A| )#{post.id}(?:\Z| )/, " ")))
    post.remove_pool!(self)
    clear_post_id_array
  end
  
  def posts(options = {})
    if options[:offset]
      limit = options[:limit] || Danbooru.config.posts_per_page
      slice = post_id_array.slice(options[:offset], limit)
      if slice && slice.any?
        Post.where("id in (?)", slice).order(arbitrary_sql_order_clause(slice, "posts"))
      else
        Post.where("false")
      end
    else
      Post.where("id IN (?)", post_id_array).order(arbitrary_sql_order_clause(post_id_array, "posts"))
    end
  end
  
  def balance_post_ids
    added = post_id_array - post_id_array_was
    removed = post_id_array_was - post_id_array
    
    added.each do |post_id|
      post = Post.find(post_id)
      post.add_pool!(self)
    end
    
    removed.each do |post_id|
      post = Post.find(post_id)
      post.remove_pool!(self)
    end
  end
  
  def post_id_array
    @post_id_array ||= post_ids.scan(/\d+/).map(&:to_i)
  end
  
  def post_id_array_was
    @post_id_array_was ||= post_ids_was.scan(/\d+/).map(&:to_i)
  end
  
  def post_id_array=(array)
    self.post_ids = array.join(" ")
    clear_post_id_array
  end
  
  def clear_post_id_array
    @post_id_array = nil
    @post_id_array_was = nil
  end
  
  def initialize_post_count
    self.post_count = post_id_array.size
  end
  
  def neighbor_posts(post)
    @neighbor_posts ||= begin
      post_ids =~ /\A#{post.id} (\d+)|(\d+) #{post.id} (\d+)|(\d+) #{post.id}\Z/
      
      if $2 && $3
        OpenStruct.new(:previous => $2.to_i, :next => $3.to_i)
      elsif $1
        OpenStruct.new(:next => $1.to_i)
      elsif $4
        OpenStruct.new(:previous => $4.to_i)
      else
        OpenStruct.new
      end
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
    @neighbor_posts = nil
    clear_post_id_array
  end
end
