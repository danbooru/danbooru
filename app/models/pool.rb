require 'ostruct'

class Pool < ActiveRecord::Base
  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of :name, :with => /\A[^\s,]+\Z/, :message => "cannot have whitespace or commas"
  validates_inclusion_of :category, :in => %w(series collection)
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  has_many :versions, :class_name => "PoolVersion", :dependent => :destroy, :order => "pool_versions.id ASC"
  before_validation :normalize_post_ids
  before_validation :normalize_name
  before_validation :initialize_is_active, :on => :create
  before_validation :initialize_creator, :on => :create
  after_save :create_version
  after_create :synchronize!
  before_destroy :create_mod_action_for_destroy
  attr_accessible :name, :description, :post_ids, :post_id_array, :post_count, :is_active, :category, :as => [:member, :gold, :platinum, :contributor, :janitor, :moderator, :admin, :default]
  attr_accessible :is_deleted, :as => [:janitor, :moderator, :admin]

  module SearchMethods
    def deleted
      where("is_deleted = true")
    end

    def undeleted
      where("is_deleted = false")
    end

    def series
      where("category = ?", "series")
    end

    def collection
      where("category = ?", "collection")
    end

    def series_first
      order("(case category when 'series' then 0 else 1 end), name")
    end

    def name_matches(name)
      name = name.tr(" ", "_")
      name = "*#{name}*" unless name =~ /\*/
      where("name ilike ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def search(params)
      q = scoped
      params = {} if params.blank?

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:description_matches].present?
        q = q.where("description like ? escape E'\\\\'", "%" + params[:description_matches].to_escaped_for_sql_like + "%")
      end

      if params[:creator_name].present?
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].tr(" ", "_").mb_chars.downcase)
      end

      if params[:creator_id].present?
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      end

      if params[:is_active] == "true"
        q = q.where("is_active = true")
      elsif params[:is_active] == "false"
        q = q.where("is_active = false")
      end

      params[:order] ||= params.delete(:sort)
      case params[:order]
      when "name"
        q = q.order("name")
      when "created_at"
        q = q.order("created_at desc")
      when "post_count"
        q = q.order("post_count desc")
      else
        q = q.order("updated_at desc")
      end

      if params[:category] == "series"
        q = q.series
      elsif params[:category] == "collection"
        q = q.collection
      end

      if params[:is_deleted] == "true"
        q = q.deleted
      else
        q = q.undeleted
      end

      q
    end
  end

  extend SearchMethods

  def self.name_to_id(name)
    if name =~ /^\d+$/
      name.to_i
    else
      select_value_sql("SELECT id FROM pools WHERE lower(name) = ?", name.mb_chars.downcase.tr(" ", "_")).to_i
    end
  end

  def self.id_to_name(id)
    select_value_sql("SELECT name FROM pools WHERE id = ?", id)
  end

  def self.options
    select_all_sql("SELECT id, name FROM pools WHERE is_active = true AND is_deleted = false ORDER BY name LIMIT 100").map {|x| [x["name"].tr("_", " "), x["id"]]}
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
    name.gsub(/\s+/, "_")
  end

  def self.normalize_post_ids(post_ids, unique)
    hoge = post_ids.scan(/\d+/)
    if unique
      hoge = hoge.uniq
    end
    hoge.join(" ")
  end

  def self.find_by_name(name)
    if name =~ /^\d+$/
      where("id = ?", name.to_i).first
    elsif name
      where("lower(name) = ?", normalize_name(name).mb_chars.downcase).first
    else
      nil
    end
  end

  def is_series?
    category == "series"
  end

  def is_collection?
    category == "collection"
  end

  def initialize_is_active
    self.is_deleted = false if is_deleted.nil?
    self.is_active = true if is_active.nil?
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end

  def normalize_name
    self.name = Pool.normalize_name(name)
  end

  def pretty_name
    name.tr("_", " ")
  end

  def pretty_category
    category.titleize
  end

  def creator_name
    User.id_to_name(creator_id)
  end

  def normalize_post_ids
    self.post_ids = self.class.normalize_post_ids(post_ids, is_collection?)
  end

  def revert_to!(version)
    self.post_ids = version.post_ids
    self.name = version.name
    synchronize!
  end

  def contains?(post_id)
    post_ids =~ /(?:\A| )#{post_id}(?:\Z| )/
  end

  def page_number(post_id)
    post_id_array.find_index(post_id).to_i + 1
  end

  def deletable_by?(user)
    user.is_janitor?
  end

  def create_mod_action_for_delete
    ModAction.create(:description => "deleted pool ##{id} (name: #{name})")
  end

  def create_mod_action_for_undelete
    ModAction.create(:description => "undeleted pool ##{id} (name: #{name})")
  end

  def create_mod_action_for_destroy
    ModAction.create(:description => "permanently deleted pool ##{id} name=#{name} post_ids=#{post_ids}")
  end

  def add!(post)
    return if contains?(post.id)
    return if is_deleted?

    update_attributes(:post_ids => add_number_to_string(post.id, post_ids), :post_count => post_count + 1)
    post.add_pool!(self, true)
    clear_post_id_array
  end

  def remove!(post)
    return unless contains?(post.id)
    return if is_deleted?

    update_attributes(:post_ids => remove_number_from_string(post.id, post_ids), :post_count => post_count - 1)
    post.remove_pool!(self, true)
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
      slice.map do |id|
        Post.find(id)
      end
    else
      []
    end
  end

  def synchronize!
    added = post_id_array - post_id_array_was
    removed = post_id_array_was - post_id_array

    added.each do |post_id|
      post = Post.find(post_id)
      post.add_pool!(self, true)
    end

    removed.each do |post_id|
      post = Post.find(post_id)
      post.remove_pool!(self, true)
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

  def create_version(force = false)
    if post_ids_changed? || name_changed? || description_changed? || is_active_changed? || is_deleted_changed? || category_changed? || force
      last_version = versions.last

      if last_version && CurrentUser.ip_addr == last_version.updater_ip_addr && CurrentUser.id == last_version.updater_id && last_version.created_at > 1.hour.ago
        last_version.update_column(:post_ids, post_ids)
        last_version.update_column(:name, name)
      else
        versions.create(:post_ids => post_ids, :name => name)
      end
    end
  end

  def last_page
    (post_count / CurrentUser.user.per_page.to_f).ceil
  end

  def reload(options = {})
    super
    @neighbor_posts = nil
    clear_post_id_array
  end

  def to_xml(options = {}, &block)
    # to_xml ignores the serializable_hash method
    options ||= {}
    options[:methods] = [:creator_name]
    super(options, &block)
  end

  def serializable_hash(options = {})
    return {
      "category" => category,
      "created_at" => created_at,
      "creator_id" => creator_id,
      "creator_name" => creator_name,
      "description" => description,
      "id" => id,
      "is_active" => is_active?,
      "is_deleted" => is_deleted?,
      "name" => name,
      "post_count" => post_count,
      "post_ids" => post_ids,
      "updated_at" => updated_at
    }
  end
end
