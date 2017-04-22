class TagSubscription < ActiveRecord::Base
  belongs_to :creator, :class_name => "User"
  before_validation :initialize_creator, :on => :create
  before_validation :initialize_post_ids, :on => :create
  before_save :normalize_name
  before_save :limit_tag_count
  attr_accessible :name, :tag_query, :post_ids, :is_public, :is_visible_on_profile
  validates_presence_of :name, :tag_query, :creator_id
  validate :validate_number_of_queries
  validate :creator_can_create_subscriptions, :on => :create

  def migrate_to_saved_searches
    tag_query.split(/\r\n|\r|\n/).each do |query|
      creator.saved_searches.create({query: query, labels: [name]}, without_protection: true)
    end
  end

  def normalize_name
    self.name = name.gsub(/\s+/, "_")
  end

  def pretty_name
    name.tr("_", " ")
  end

  def pretty_tag_query
    tag_query_array.join(", ")
  end

  def initialize_creator
    self.creator_id = CurrentUser.id
  end

  def initialize_post_ids
    process
  end

  def creator_can_create_subscriptions
    if TagSubscription.owned_by(creator).count >= Danbooru.config.max_tag_subscriptions
      self.errors.add(:creator, "can create up to #{Danbooru.config.max_tag_subscriptions} tag subscriptions")
      return false
    else
      return true
    end
  end

  def validate_number_of_queries
    if tag_query_array.size > 20 || tag_query_array.size < 1
      self.errors.add(:tag_query, "can have up to 20 queries")
      return false
    else
      return true
    end
  end

  def tag_query_array
    tag_query.scan(/[^\r\n]+/).map(&:strip)
  end

  def limit_tag_count
    # self.tag_query = tag_query_array.slice(0, 20).join(" ")
  end

  def process
    divisor = [tag_query_array.size / 2, 1].max
    post_ids = tag_query_array.inject([]) do |all, query|
      all += PostReadOnly.tag_match(query).limit(Danbooru.config.tag_subscription_post_limit / divisor).select("posts.id").order("posts.id DESC").map(&:id)
    end
    self.post_ids = post_ids.sort.reverse.slice(0, Danbooru.config.tag_subscription_post_limit).join(",")
  end

  def is_active?
    creator.is_gold? && creator.last_logged_in_at && creator.last_logged_in_at > 3.months.ago
  end

  def editable_by?(user)
    user.is_moderator? || creator_id == user.id
  end

  def post_id_array
    post_ids.split(/,/)
  end

  module SearchMethods
    def visible_to(user)
      where("(is_public = TRUE OR creator_id = ? OR ?)", user.id, user.is_moderator?)
    end

    def owned_by(user)
      where("creator_id = ?", user.id)
    end

    def name_matches(name)
      where("lower(name) like ? escape E'\\\\'", name.to_escaped_for_sql_like)
    end

    def search(params)
      q = where("true")
      params = {} if params.blank?

      if params[:creator_id]
        q = q.where("creator_id = ?", params[:creator_id].to_i)
      elsif params[:creator_name]
        q = q.where("creator_id = (select _.id from users _ where lower(_.name) = ?)", params[:creator_name].mb_chars.downcase.strip.tr(" ", "_"))
      else
        q = q.where("creator_id = ?", CurrentUser.user.id)
      end

      if params[:name_matches]
        q = q.name_matches(params[:name_matches].mb_chars.downcase.strip.tr(" ", "_"))
      end

      q = q.visible_to(CurrentUser.user)

      q
    end
  end

  extend SearchMethods

  def self.find_tags(subscription_name)
    if subscription_name =~ /^(.+?):(.+)$/
      user_name = $1
      sub_group = $2
    else
      user_name = subscription_name
      sub_group = nil
    end

    user = User.find_by_name(user_name)

    if user
      relation = where(["creator_id = ?", user.id])

      if sub_group
        relation = relation.where(["name ILIKE ? ESCAPE E'\\\\'", sub_group.to_escaped_for_sql_like])
      end

      relation.map {|x| x.tag_query_array}.flatten
    else
      []
    end
  end

  def self.find_post_ids(user_id, name = nil, limit = Danbooru.config.tag_subscription_post_limit)
    relation = where("creator_id = ?", user_id)

    if name
      relation = relation.where("lower(name) LIKE ? ESCAPE E'\\\\'", name.mb_chars.downcase.to_escaped_for_sql_like)
    end

    relation.each do |tag_sub|
      tag_sub.update_column(:last_accessed_at, Time.now)
    end

    relation.map {|x| x.post_ids.split(/,/)}.flatten.uniq.map(&:to_i).sort.reverse.slice(0, limit)
  end

  def self.find_posts(user_id, name = nil, limit = Danbooru.config.tag_subscription_post_limit)
    arel = Post.where(["id in (?)", find_post_ids(user_id, name, limit)])

    if CurrentUser.user.hide_deleted_posts?
      arel = arel.where("is_deleted = false")
    end

    arel.order("id DESC").limit(limit)
  end

  def self.process(id)
    tag_subscription = TagSubscription.find(id)
    CurrentUser.scoped(tag_subscription.creator, "127.0.0.1") do
      tag_subscription.process
      tag_subscription.save
    end
  rescue Exception => x
    raise if Rails.env != "production"
  end

  def self.process_all
    find_each do |tag_subscription|
      if tag_subscription.is_active?
        time = rand(20 * 60 * 60).seconds.from_now
        TagSubscription.delay(:run_at => time, :queue => "default", :priority => 10).process(tag_subscription.id)
      end
    end
  end
end
