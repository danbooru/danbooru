class FavoriteGroup < ApplicationRecord
  validates_uniqueness_of :name, :case_sensitive => false, :scope => :creator_id
  validates_format_of :name, :with => /\A[^,]+\Z/, :message => "cannot have commas"
  belongs_to_creator
  before_validation :normalize_name
  before_validation :strip_name
  validate :creator_can_create_favorite_groups, :on => :create
  validate :validate_number_of_posts

  array_attribute :post_ids, parse: /\d+/, cast: :to_i

  module SearchMethods
    def for_creator(user_id)
      where("favorite_groups.creator_id = ?", user_id)
    end

    def for_post(post_id)
      where_array_includes_any(:post_ids, [post_id])
    end

    def named(name)
      where("lower(name) = ?", name.to_s.mb_chars.downcase.strip)
    end

    def name_matches(name)
      name = name.tr(" ", "_")
      name = "*#{name}*" unless name =~ /\*/
      where("name ilike ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def hide_private(user, params)
      if user.hide_favorites?
        where("is_public = true")
      elsif params[:is_public].present?
        where("is_public = ?", params[:is_public])
      else
        all
      end
    end

    def default_order
      order(name: :asc)
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :name, :is_public, :post_ids)

      if params[:creator_id].present?
        user = User.find(params[:creator_id])
        q = q.hide_private(user, params)
        q = q.where("creator_id = ?", user.id)
      elsif params[:creator_name].present?
        user = User.find_by_name(params[:creator_name])
        q = q.hide_private(user, params)
        q = q.where("creator_id = ?", user.id)
      else
        q = q.hide_private(CurrentUser.user, params)
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
    end
  end

  def validate_number_of_posts
    if post_count > 10_000
      errors[:base] << "Favorite groups can have up to 10,000 posts each"
    end
  end

  def self.normalize_name(name)
    name.gsub(/[[:space:]]+/, "_")
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

  def strip_name
    self.name = name.to_s.strip
  end

  def pretty_name
    name.tr("_", " ")
  end

  def posts
    favgroup_posts = FavoriteGroup.where(id: id).joins("CROSS JOIN unnest(favorite_groups.post_ids) WITH ORDINALITY AS row(post_id, favgroup_index)").select(:post_id, :favgroup_index)
    posts = Post.joins("JOIN (#{favgroup_posts.to_sql}) favgroup_posts ON favgroup_posts.post_id = posts.id").order("favgroup_posts.favgroup_index ASC")
  end

  def add!(post)
    with_lock do
      return if contains?(post.id)
      update!(post_ids: post_ids + [post.id])
    end
  end

  def remove!(post)
    with_lock do
      return unless contains?(post.id)
      update!(post_ids: post_ids - [post.id])
    end
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

  def last_page
    (post_count / CurrentUser.user.per_page.to_f).ceil
  end

  def contains?(post_id)
    post_ids.include?(post_id)
  end

  def editable_by?(user)
    creator_id == user.id
  end

  def viewable_by?(user)
    creator_id == user.id || !creator.hide_favorites? || is_public
  end
end
