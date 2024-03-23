# frozen_string_literal: true

class Pool < ApplicationRecord
  class RevertError < StandardError; end

  RESERVED_NAMES = %w[none any series collection]
  POOL_ORDER_LIMIT = 1000

  array_attribute :post_ids, parse: /\d+/, cast: :to_i

  validates :name, visible_string: true, uniqueness: { case_sensitive: false }, length: { minimum: 3, maximum: 170 }, if: :name_changed?
  validate :validate_name, if: :name_changed?
  validates :description, length: { maximum: 20_000 }, if: :description_changed?
  validates :category, inclusion: { in: %w[series collection] }
  validate :updater_can_edit_deleted
  before_validation :normalize_post_ids
  before_validation :normalize_name
  after_save :create_version

  has_many :mod_actions, as: :subject, dependent: :destroy
  has_many :reactions, as: :model, dependent: :destroy

  deletable
  has_dtext_links :description

  scope :series, -> { where(category: "series") }
  scope :collection, -> { where(category: "collection") }

  module SearchMethods
    def name_contains(name)
      name = normalize_name_for_search(name)
      name = "*#{name}*" unless name =~ /\*/
      where_ilike(:name, name)
    end

    def post_tags_match(query)
      posts = Post.user_tag_match(query).select(:id).reorder(nil)
      pools = Pool.joins("CROSS JOIN unnest(post_ids) AS post_id").group(:id).where("post_id IN (?)", posts)
      where(id: pools)
    end

    def default_order
      order(updated_at: :desc)
    end

    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_deleted, :name, :description, :post_ids, :dtext_links], current_user: current_user)

      if params[:post_tags_match]
        q = q.post_tags_match(params[:post_tags_match])
      end

      if params[:name_contains].present?
        q = q.name_contains(params[:name_contains])
      end

      if params[:linked_to].present?
        q = q.linked_to(params[:linked_to])
      end

      if params[:not_linked_to].present?
        q = q.not_linked_to(params[:not_linked_to])
      end

      case params[:category]
      when "series"
        q = q.series
      when "collection"
        q = q.collection
      end

      case params[:order]
      when "name"
        q = q.order("pools.name")
      when "created_at"
        q = q.order("pools.created_at desc")
      when "post_count"
        q = q.order(Arel.sql("cardinality(post_ids) desc")).default_order
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def self.normalize_name(name)
    name.gsub(/[_[:space:]]+/, "_").gsub(/\A_|_\z/, "")
  end

  def self.normalize_name_for_search(name)
    normalize_name(name).downcase
  end

  def self.named(name)
    if name =~ /^\d+$/
      where(id: name.to_i)
    elsif name
      where_ilike(:name, normalize_name_for_search(name))
    else
      nil
    end
  end

  def self.find_by_name(name)
    named(name).try(:first)
  end

  def versions
    raise NotImplementedError, "Archive service not configured" unless PoolVersion.enabled?
    PoolVersion.where(pool_id: id).order("id asc")
  end

  def is_series?
    category == "series"
  end

  def is_collection?
    category == "collection"
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

  def normalize_post_ids
    self.post_ids = post_ids.uniq
  end

  def revert_to!(version)
    if id != version.pool_id
      raise RevertError, "You cannot revert to a previous version of another pool."
    end

    self.post_ids = version.post_ids
    self.name = version.name
    self.description = version.description
    save!
  end

  def contains?(post_id)
    post_ids.include?(post_id)
  end

  def page_number(post_id)
    post_ids.find_index(post_id).to_i + 1
  end

  def updater_can_edit_deleted
    if is_deleted? && !Pundit.policy!(CurrentUser.user, self).update?
      errors.add(:base, "You cannot update pools that are deleted")
    end
  end

  def create_mod_action_for_delete
    ModAction.log("deleted pool ##{id} (name: #{name})", :pool_delete, subject: self, user: CurrentUser.user)
  end

  def create_mod_action_for_undelete
    ModAction.log("undeleted pool ##{id} (name: #{name})", :pool_undelete, subject: self, user: CurrentUser.user)
  end

  def add!(post)
    return if contains?(post.id)
    return if is_deleted?

    with_lock do
      update(post_ids: post_ids + [post.id])
    end
  end

  def remove!(post)
    return unless contains?(post.id)

    with_lock do
      reload
      update(post_ids: post_ids - [post.id])
    end
  end

  # XXX unify with PostQueryBuilder ordpool search
  def posts
    pool_posts = Pool.where(id: id).joins("CROSS JOIN unnest(pools.post_ids) WITH ORDINALITY AS row(post_id, pool_index)").select(:post_id, :pool_index)
    Post.joins("JOIN (#{pool_posts.to_sql}) pool_posts ON pool_posts.post_id = posts.id").order("pool_posts.pool_index ASC")
  end

  def post_count
    post_ids.size
  end

  def first_post?(post_id)
    post_id == post_ids.first
  end

  def last_post?(post_id)
    post_id == post_ids.last
  end

  # XXX finds wrong post when the pool contains multiple copies of the same post (#2042).
  def previous_post_id(post_id)
    return nil if first_post?(post_id) || !contains?(post_id)

    n = post_ids.index(post_id) - 1
    post_ids[n]
  end

  def next_post_id(post_id)
    return nil if last_post?(post_id) || !contains?(post_id)

    n = post_ids.index(post_id) + 1
    post_ids[n]
  end

  def cover_post
    post_count > 0 ? Post.find(post_ids.first) : nil
  end

  def create_version(updater: CurrentUser.user)
    if PoolVersion.enabled?
      PoolVersion.queue(self, updater)
    else
      Rails.logger.warn("Archive service is not configured. Pool versions will not be saved.")
    end
  end

  def last_page
    (post_count / CurrentUser.user.per_page.to_f).ceil
  end

  def validate_name
    case name.downcase
    when *RESERVED_NAMES
      errors.add(:name, "cannot be any of the following names: #{RESERVED_NAMES.to_sentence(last_word_connector: ", or ")}")
    when /,/
      errors.add(:name, "cannot contain commas")
    when /\*/
      errors.add(:name, "cannot contain asterisks")
    when /\A_/
      errors.add(:name, "cannot begin with an underscore")
    when /_\z/
      errors.add(:name, "cannot end with an underscore")
    when /__/
      errors.add(:name, "cannot contain consecutive underscores")
    when /[^[:graph:]]/
      errors.add(:name, "cannot contain non-printable characters")
    when ""
      errors.add(:name, "cannot be blank")
    when /\A[0-9]+\z/
      errors.add(:name, "cannot contain only digits")
    end
  end

  def self.rewrite_wiki_links!(old_name, new_name)
    Pool.linked_to(old_name).each do |pool|
      pool.with_lock do
        pool.update!(description: DText.new(pool.description).rewrite_wiki_links(old_name, new_name).to_s)
      end
    end
  end
end
