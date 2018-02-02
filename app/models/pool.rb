require 'ostruct'

class Pool < ApplicationRecord
  class RevertError < Exception ; end

  validates_uniqueness_of :name, :case_sensitive => false, :if => :name_changed?
  validate :validate_name, :if => :name_changed?
  validates_inclusion_of :category, :in => %w(series collection)
  validate :updater_can_change_category
  validate :updater_can_remove_posts
  validate :updater_can_edit_deleted
  belongs_to :creator, :class_name => "User"
  belongs_to :updater, :class_name => "User"
  before_validation :normalize_post_ids
  before_validation :normalize_name
  before_validation :initialize_is_active, :on => :create
  before_validation :initialize_creator, :on => :create
  after_save :update_category_pseudo_tags_for_posts_async
  after_save :create_version
  after_create :synchronize!
  before_destroy :create_mod_action_for_destroy

  module SearchMethods
    def deleted
      where("pools.is_deleted = true")
    end

    def undeleted
      where("pools.is_deleted = false")
    end

    def series
      where("pools.category = ?", "series")
    end

    def collection
      where("pools.category = ?", "collection")
    end

    def series_first
      order("(case pools.category when 'series' then 0 else 1 end), pools.name")
    end

    def name_matches(name)
      name = normalize_name_for_search(name)
      name = "*#{name}*" unless name =~ /\*/
      where("lower(pools.name) like ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params)
      q = super

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:description_matches].present?
        q = q.where("lower(pools.description) like ? escape E'\\\\'", "%" + params[:description_matches].mb_chars.downcase.to_escaped_for_sql_like + "%")
      end

      if params[:creator_name].present?
        q = q.where("pools.creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].tr(" ", "_").mb_chars.downcase)
      end

      if params[:creator_id].present?
        q = q.where(creator_id: params[:creator_id].split(",").map(&:to_i))
      end

      if params[:is_active] == "true"
        q = q.where("pools.is_active = true")
      elsif params[:is_active] == "false"
        q = q.where("pools.is_active = false")
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

      params[:order] ||= params.delete(:sort)
      case params[:order]
      when "name"
        q = q.order("pools.name")
      when "created_at"
        q = q.order("pools.created_at desc")
      when "post_count"
        q = q.order("pools.post_count desc").default_order
      else
        q = q.apply_default_order(params)
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

  def self.normalize_name(name)
    name.gsub(/[_[:space:]]+/, "_").gsub(/\A_|_\z/, "")
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
      where("pools.id = ?", name.to_i).first
    elsif name
      where("lower(pools.name) = ?", normalize_name_for_search(name)).first
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
    user.is_builder?
  end

  def updater_can_edit_deleted
    if is_deleted? && !deletable_by?(CurrentUser.user)
      errors[:base] << "You cannot update pools that are deleted"
      false
    else
      true
    end
  end

  def create_mod_action_for_delete
    ModAction.log("deleted pool ##{id} (name: #{name})",:pool_delete)
  end

  def create_mod_action_for_undelete
    ModAction.log("undeleted pool ##{id} (name: #{name})",:pool_undelete)
  end

  def add!(post)
    return if contains?(post.id)
    return if is_deleted?

    with_lock do
      update_attributes(:post_ids => add_number_to_string(post.id, post_ids), :post_count => post_count + 1)
      post.add_pool!(self, true)
      clear_post_id_array
    end
  end

  def remove!(post)
    return unless contains?(post.id)
    return unless CurrentUser.user.can_remove_from_pools?

    with_lock do
      update_attributes(:post_ids => remove_number_from_string(post.id, post_ids), :post_count => post_count - 1)
      post.remove_pool!(self)
      clear_post_id_array
    end
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
      post.remove_pool!(self)
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
    self
  end

  def method_attributes
    super + [:creator_name]
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

  def validate_name
    case name
    when /\A(any|none|series|collection)\z/i
      errors[:name] << "cannot be any of the following names: any, none, series, collection"
    when /,/
      errors[:name] << "cannot contain commas"
    when /\*/
      errors[:name] << "cannot contain asterisks"
    when ""
      errors[:name] << "cannot be blank"
    when /\A[0-9]+\z/
      errors[:name] << "cannot contain only digits"
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
