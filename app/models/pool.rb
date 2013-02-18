require 'ostruct'

class Pool < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_format_of :name, :with => /\A[^\s;,]+\Z/, :on => :create, :message => "cannot have whitespace, commas, or semicolons"
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :versions, :class_name => "PoolVersion", :dependent => :destroy, :order => "pool_versions.id ASC"
  before_validation :normalize_name
  before_validation :normalize_post_ids
  before_validation :initialize_is_active, :on => :create
  before_validation :initialize_creator, :on => :create
  after_save :create_version
  before_destroy :create_mod_action_for_destroy
  attr_accessible :name, :description, :post_ids, :post_id_array, :post_count, :is_active, :as => [:member, :privileged, :contributor, :janitor, :moderator, :admin, :default]
  attr_accessible :is_deleted, :as => [:janitor, :moderator, :admin]

  module SearchMethods
    def active
      where("is_active = true and is_deleted = false")
    end
    
    def search(params)
      q = scoped
      return q if params.blank?
      
      if params[:name_matches].present?
        params[:name_matches] += "*" unless params[:name_matches] =~ /\*/
        q = q.where("name ilike ? escape E'\\\\'", params[:name_matches].to_escaped_for_sql_like)
      end
      
      if params[:description_matches].present?
        q = q.where("description like ? escape E'\\\\'", params[:description_matches].to_escaped_for_sql_like)
      end
      
      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].downcase)
      end
      
      if params[:creator_id].present?
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      end
      
      if params[:sort] == "updated_at"
        q = q.order("updated_at desc")
      else
        q = q.order("name")
      end
      
      q
    end
  end
  
  extend SearchMethods
    
  def self.name_to_id(name)
    if name =~ /^\d+$/
      name.to_i
    else
      select_value_sql("SELECT id FROM pools WHERE name = ?", name.downcase).to_i
    end
  end
  
  def self.id_to_name(id)
    select_value_sql("SELECT name FROM pools WHERE id = ?", id)
  end
  
  def self.options
    select_all_sql("SELECT id, name FROM pools WHERE is_active = true AND is_deleted = false ORDER BY name LIMIT 100").map {|x| [x["name"], x["id"]]}
  end
  
  def self.create_anonymous
    Pool.new do |pool|
      pool.name = "TEMP:#{Time.now.to_f}.#{rand(1_000_000)}"
      pool.save
      pool.name = "anon:#{pool.id}"
      pool.save
    end
  end
  
  def self.normalize_name(name)
    name.downcase.gsub(/\s+/, "_")
  end
  
  def self.normalize_post_ids(post_ids)
    post_ids.scan(/\d+/).join(" ")
  end
  
  def self.find_by_name(name)
    if name =~ /^\d+$/
      where("id = ?", name.to_i).first
    elsif name
      where("name = ?", normalize_name(name)).first
    else
      nil
    end
  end
  
  def initialize_is_active
    self.is_deleted = false if is_deleted.nil?
    self.is_active = true if is_active.nil?
  end
  
  def initialize_creator
    self.creator_id = CurrentUser.id
  end
  
  def pretty_name
    name.tr("_", " ")
  end
  
  def normalize_name
    self.name = self.class.normalize_name(name)
  end
  
  def normalize_post_ids
    self.post_ids = self.class.normalize_post_ids(post_ids)
  end
  
  def revert_to!(version)
    self.post_ids = version.post_ids
    synchronize!
  end

  def contains?(post_id)
    post_ids =~ /(?:\A| )#{post_id}(?:\Z| )/
  end
  
  def deletable_by?(user)
    user.is_janitor?
  end
  
  def create_mod_action_for_destroy
    ModAction.create(:description => "deleted pool ##{id} name=#{name} post_ids=#{post_ids}")
  end
  
  def add!(post)
    return if contains?(post.id)
    
    update_attributes(:post_ids => add_number_to_string(post.id, post_ids), :post_count => post_count + 1)
    post.add_pool!(self)
    clear_post_id_array
  end
  
  def remove!(post)
    return unless contains?(post.id)
    
    update_attributes(:post_ids => remove_number_from_string(post.id, post_ids), :post_count => post_count - 1)
    post.remove_pool!(self)
    clear_post_id_array
  end
  
  def add_number_to_string(number, string)
    "#{string} #{number}"
  end
  
  def remove_number_from_string(number, string)
    string.gsub(/(?:\A| )#{number}(?:\Z| )/, " ")
  end
  
  def posts(options = {})
    offset = options[:offset] || 0
    limit = options[:limit] || Danbooru.config.posts_per_page
    slice = post_id_array.slice(offset, limit)
    if slice && slice.any?
      Post.where("id in (?)", slice).order(arbitrary_sql_order_clause(slice, "posts"))
    else
      Post.where("false")
    end
  end
  
  def synchronize!
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
    
    self.post_count = post_id_array.size
    save
  end
  
  def post_id_array
    @post_id_array ||= post_ids.scan(/\d+/).map(&:to_i)
  end
  
  def post_id_array=(array)
    self.post_ids = array.join(" ")
    clear_post_id_array
  end
  
  def post_id_array_was
    @post_id_array_was ||= post_ids_was.scan(/\d+/).map(&:to_i)
  end
  
  def clear_post_id_array
    @post_id_array = nil
    @post_id_array_was = nil
  end
  
  def neighbors(post)
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
      last_version.update_column(:post_ids, post_ids)
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
