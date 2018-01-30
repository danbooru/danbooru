require 'ostruct'

class FavoriteGroup < ApplicationRecord
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :creator_id
  validates_format_of :name, :with => /\A[^,]+\Z/, :message => "cannot have commas"
  belongs_to :creator, :class_name => "User"
  before_validation :normalize_post_ids
  before_validation :normalize_name
  before_validation :initialize_creator, :on => :create
  before_validation :strip_name
  validate :creator_can_create_favorite_groups, :on => :create
  validate :validate_number_of_posts
  before_save :update_post_count

  module SearchMethods
    def for_creator(user_id)
      where("favorite_groups.creator_id = ?", user_id)
    end

    def for_post(post_id)
      regexp = "(^#{post_id}$|^#{post_id} | #{post_id}$| #{post_id} )"
      where("favorite_groups.post_ids ~ ?", regexp)
    end

    def named(name)
      where("lower(name) = ?", name.to_s.mb_chars.downcase.strip)
    end

    def name_matches(name)
      name = name.tr(" ", "_")
      name = "*#{name}*" unless name =~ /\*/
      where("name ilike ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def hide_private(user,params)
      if user.hide_favorites?
        where("is_public = true")
      elsif params[:is_public].present?
        where("is_public = ?", params[:is_public])
      else
        all
      end
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params)
      q = super

      if params[:creator_id].present?
        user = User.find(params[:creator_id])
        q = q.hide_private(user,params)
        q = q.where("creator_id = ?", user.id)
      elsif params[:creator_name].present?
        user = User.find_by_name(params[:creator_name])
        q = q.hide_private(user,params)
        q = q.where("creator_id = ?", user.id)
      else
        q = q.hide_private(CurrentUser.user,params)
        q = q.where("creator_id = ?", CurrentUser.user.id)
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def self.name_to_id(name)
    if name =~ /^\d+$/
      name.to_i
    else
      select_value_sql("SELECT id FROM favorite_groups WHERE lower(name) = ? AND creator_id = ?", name.to_s.mb_chars.downcase.tr(" ", "_"), CurrentUser.user.id).to_i
    end
  end

  def creator_can_create_favorite_groups
    if creator.favorite_group_count >= creator.favorite_group_limit
      error = "You can only keep up to #{creator.favorite_group_limit} favorite groups."
      if !CurrentUser.user.is_platinum?
        error += " Upgrade your account to create more."
      end
      self.errors.add(:base, error)
      return false
    else
      return true
    end
  end

  def validate_number_of_posts
    if post_id_array.size > 10_000
      self.errors.add(:base, "Favorite groups can have up to 10,000 posts each")
      return false
    else
      return true
    end
  end

  def normalize_post_ids
    self.post_ids = post_ids.scan(/\d+/).uniq.join(" ")
  end

  def self.normalize_name(name)
    name.gsub(/\s+/, "_")
  end

  def normalize_name
    self.name = FavoriteGroup.normalize_name(name)
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

  def initialize_creator
    self.creator_id ||= CurrentUser.id
  end

  def strip_name
    self.name = name.to_s.strip
  end

  def pretty_name
    name.tr("_", " ")
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

  def update_post_count
    normalize_post_ids
    clear_post_id_array
    self.post_count = post_id_array.size
  end

  def add!(post_id)
    with_lock do
      post_id = post_id.id if post_id.is_a?(Post)
      return if contains?(post_id)

      clear_post_id_array
      update_attributes(:post_ids => add_number_to_string(post_id, post_ids))
    end
  end

  def self.purge_post(post_id)
    post_id = post_id.id if post_id.is_a?(Post)
    for_post(post_id).find_each do |group|
      group.remove!(post_id)
    end
  end

  def remove!(post_id)
    with_lock do
      post_id = post_id.id if post_id.is_a?(Post)
      return unless contains?(post_id)

      clear_post_id_array
      update_attributes(:post_ids => remove_number_from_string(post_id, post_ids))
    end
  end

  def add_number_to_string(number, string)
    "#{string} #{number}"
  end

  def remove_number_from_string(number, string)
    string.gsub(/(?:\A| )#{number}(?:\Z| )/, " ")
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

  def reload(options = {})
    super
    @neighbor_posts = nil
    clear_post_id_array
    self
  end

  def last_page
    (post_count / CurrentUser.user.per_page.to_f).ceil
  end

  def contains?(post_id)
    post_ids =~ /(?:\A| )#{post_id}(?:\Z| )/
  end

  def editable_by?(user)
    creator_id == user.id
  end

  def viewable_by?(user)
    creator_id == user.id || !creator.hide_favorites? || is_public
  end
end
