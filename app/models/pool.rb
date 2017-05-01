require 'ostruct'

class Pool < ActiveRecord::Base
  class RevertError < Exception ; end

  validates_uniqueness_of :name, :case_sensitive => false
  validates_format_of :name, :with => /\A[^,]+\Z/, :message => "cannot have commas"
  validates_inclusion_of :category, :in => %w(series collection)
  validate :updater_can_change_category
  validate :name_does_not_conflict_with_metatags
  validate :updater_can_remove_posts
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  before_validation :normalize_post_ids
  before_validation :normalize_name
  before_validation :initialize_is_active, :on => :create
  before_validation :initialize_creator, :on => :create
  before_validation :strip_name
  after_save :update_category_pseudo_tags_for_posts_async
  after_save :create_version
  after_create :synchronize!
  before_destroy :create_mod_action_for_destroy
  attr_accessible :name, :description, :post_ids, :post_id_array, :post_count, :is_active, :category, :as => [:member, :gold, :platinum, :moderator, :admin, :default]
  attr_accessible :is_deleted, :as => [:moderator, :admin]

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
      name = normalize_name_for_search(name)
      name = "*#{name}*" unless name =~ /\*/
      where("lower(name) like ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def search(params)
      q = where("true")
      params = {} if params.blank?

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:id].present?
        q = q.where("id in (?)", params[:id].split(","))
      end

      if params[:description_matches].present?
        q = q.where("lower(description) like ? escape E'\\\\'", "%" + params[:description_matches].mb_chars.downcase.to_escaped_for_sql_like + "%")
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
      select_value_sql("SELECT id FROM pools WHERE lower(name) = ?", name.downcase.tr(" ", "_")).to_i
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

  def self.normalize_name_for_search(name)
    normalize_name(name).mb_chars.downcase
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

  def versions
    if PoolArchive.enabled?
      PoolArchive.where("pool_id = ?", id).order("id asc")
    else
      raise "Archive service not configured"
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
    if id != version.pool_id
      raise RevertError.new("You cannot revert to a previous version of another pool.")
    end

    self.post_ids = version.post_ids.join(" ")
    self.name = version.name
    self.description = version.description

    synchronize!
  end

  def contains?(post_id)
    post_ids =~ /(?:\A| )#{post_id}(?:\Z| )/
  end

  def page_number(post_id)
    post_id_array.find_index(post_id).to_i + 1
  end

  def deletable_by?(user)
    user.is_moderator?
  end

  def create_mod_action_for_delete
    ModAction.log("deleted pool ##{id} (name: #{name})")
  end

  def create_mod_action_for_undelete
    ModAction.log("undeleted pool ##{id} (name: #{name})")
  end

  def create_mod_action_for_destroy
    ModAction.log("permanently deleted pool ##{id} name=#{name} post_ids=#{post_ids}")
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
    return unless CurrentUser.user.can_remove_from_pools?
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
        begin
          Post.find(id)
        rescue ActiveRecord::RecordNotFound
          # swallow
        end
      end.compact
    else
      []
    end
  end

  def synchronize
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

    normalize_post_ids
    clear_post_id_array
    self.post_count = post_id_array.size
  end

  def synchronize!
    synchronize
    save if post_ids_changed?
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

  def cover_post_id
    post_ids[/^(\d+)/, 1]
  end

  def create_version(force = false)
    if PoolArchive.enabled?
      PoolArchive.queue(self)
    else
      Rails.logger.warn("Archive service is not configured. Pool versions will not be saved.")
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

  def method_attributes
    super + [:creator_name]
  end

  def strip_name
    self.name = name.to_s.strip
  end

  def update_category_pseudo_tags_for_posts_async
    if category_changed?
      delay(:queue => "default").update_category_pseudo_tags_for_posts
    end
  end

  def update_category_pseudo_tags_for_posts
    Post.where("id in (?)", post_id_array).find_each do |post|
      post.reload
      post.set_pool_category_pseudo_tags
      Post.where(:id => post.id).update_all(:pool_string => post.pool_string)
    end
  end

  def category_changeable_by?(user)
    user.is_builder? || (user.is_member? && post_count <= 100)
  end

  def updater_can_change_category
    if category_changed? && !category_changeable_by?(CurrentUser.user)
      errors[:base] << "You cannot change the category of pools with greater than 100 posts"
      false
    else
      true
    end
  end

  def name_does_not_conflict_with_metatags
    if %w(any none series collection).include?(name.downcase.tr(" ", "_"))
      errors[:base] << "Pools cannot have the following names: any, none, series, collection"
      false
    else
      true
    end
  end

  def updater_can_remove_posts
    removed = post_id_array_was - post_id_array
    if removed.any? && !CurrentUser.user.can_remove_from_pools?
      errors[:base] << "You cannot removes posts from pools within the first week of sign up"
      false
    else
      true
    end
  end
end
