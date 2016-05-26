class TagImplication < ActiveRecord::Base
  attr_accessor :skip_secondary_validations

  before_save :update_descendant_names
  after_save :update_descendant_names_for_parents
  after_destroy :update_descendant_names_for_parents
  belongs_to :creator, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :forum_topic
  before_validation :initialize_creator, :on => :create
  before_validation :normalize_names
  validates_presence_of :creator_id, :antecedent_name, :consequent_name
  validates_uniqueness_of :antecedent_name, :scope => :consequent_name
  validate :absence_of_circular_relation
  validate :antecedent_is_not_aliased
  validate :consequent_is_not_aliased
  validate :antecedent_and_consequent_are_different
  validate :wiki_pages_present, :on => :create
  attr_accessible :antecedent_name, :consequent_name, :descendant_names, :forum_topic_id, :status, :forum_topic, :skip_secondary_validations

  module DescendantMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # assumes names are normalized
      def with_descendants(names)
        (names + where("antecedent_name in (?) and status in (?)", names, ["active", "processing"]).map(&:descendant_names_array)).flatten.uniq
      end
    end

    def descendants
      @descendants ||= begin
        [].tap do |all|
          children = [consequent_name]

          until children.empty?
            all.concat(children)
            children = TagImplication.where("antecedent_name IN (?) and status in (?)", children, ["active", "processing"]).map(&:consequent_name)
          end
        end.sort.uniq
      end
    end

    def descendant_names_array
      descendant_names.split(/ /)
    end

    def update_descendant_names
      self.descendant_names = descendants.join(" ")
    end

    def update_descendant_names!
      clear_descendants_cache
      update_descendant_names
      update_column(:descendant_names, descendant_names)
    end

    def update_descendant_names_for_parents
      parents.each do |parent|
        parent.update_descendant_names!
        parent.update_descendant_names_for_parents
      end
    end

    def clear_descendants_cache
      @descendants = nil
    end
  end

  module ParentMethods
    def parents
      @parents ||= self.class.where(["consequent_name = ?", antecedent_name])
    end

    def clear_parents_cache
      @parents = nil
    end
  end

  module SearchMethods
    def name_matches(name)
      where("(antecedent_name like ? escape E'\\\\' or consequent_name like ? escape E'\\\\')", name.downcase.to_escaped_for_sql_like, name.downcase.to_escaped_for_sql_like)
    end

    def active
      where("status IN (?)", ["active", "processing"])
    end

    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:id].present?
        q = q.where("id in (?)", params[:id].split(",").map(&:to_i))
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:antecedent_name].present?
        q = q.where("antecedent_name = ?", params[:antecedent_name])
      end

      if params[:consequent_name].present?
        q = q.where("consequent_name = ?", params[:consequent_name])
      end

      case params[:order]
      when "created_at"
        q = q.order("created_at desc")
      end

      q
    end
  end

  include DescendantMethods
  include ParentMethods
  extend SearchMethods

  def initialize_creator
    self.creator_id = CurrentUser.user.id
    self.creator_ip_addr = CurrentUser.ip_addr
  end

  def process!(update_topic=true)
    unless valid?
      raise errors.full_messages.join("; ")
    end

    tries = 0

    begin
      admin = CurrentUser.user || approver || User.admins.first
      CurrentUser.scoped(admin, "127.0.0.1") do
        update_column(:status, "processing")
        update_posts
        update_column(:status, "active")
        update_descendant_names_for_parents
        update_forum_topic_for_approve if update_topic
      end
    rescue Exception => e
      if tries < 5
        tries += 1
        sleep 2 ** tries
        retry
      end

      update_forum_topic_for_error(e)
      update_column(:status, "error: #{e}")
      NewRelic::Agent.notice_error(e, :custom_params => {:tag_implication_id => id, :antecedent_name => antecedent_name, :consequent_name => consequent_name})
    end
  end

  def absence_of_circular_relation
    # We don't want a -> b && b -> a chains
    if self.class.active.exists?(["antecedent_name = ? and consequent_name = ?", consequent_name, antecedent_name])
      self.errors[:base] << "Tag implication can not create a circular relation with another tag implication"
      false
    end
  end

  def antecedent_is_not_aliased
    # We don't want to implicate a -> b if a is already aliased to c
    if TagAlias.active.exists?(["antecedent_name = ?", antecedent_name])
      self.errors[:base] << "Antecedent tag must not be aliased to another tag"
      false
    end
  end

  def consequent_is_not_aliased
    # We don't want to implicate a -> b if b is already aliased to c
    if TagAlias.active.exists?(["antecedent_name = ?", consequent_name])
      self.errors[:base] << "Consequent tag must not be aliased to another tag"
      false
    end
  end

  def antecedent_and_consequent_are_different
    normalize_names
    if antecedent_name == consequent_name
      self.errors[:base] << "Cannot implicate a tag to itself"
      false
    end
  end

  def update_posts
    Post.without_timeout do
      Post.raw_tag_match(antecedent_name).where("true /* TagImplication#update_posts */").find_each do |post|
        fixed_tags = "#{post.tag_string} #{descendant_names}".strip
        CurrentUser.scoped(creator, creator_ip_addr) do
          post.update_attributes(
            :tag_string => fixed_tags
          )
        end
      end
    end
  end
  
  def normalize_names
    self.antecedent_name = antecedent_name.downcase.tr(" ", "_")
    self.consequent_name = consequent_name.downcase.tr(" ", "_")
  end

  def is_pending?
    status == "pending"
  end

  def is_active?
    status == "active"
  end

  def antecedent_tag
    Tag.find_or_create_by_name(antecedent_name)
  end

  def consequent_tag
    Tag.find_or_create_by_name(consequent_name)
  end

  def reload(options = {})
    super
    clear_parents_cache
    clear_descendants_cache
  end

  def deletable_by?(user)
    return true if user.is_admin?
    return true if is_pending? && user.is_builder?
    return true if is_pending? && user.id == creator_id
    return false
  end

  def editable_by?(user)
    deletable_by?(user)
  end

  def update_forum_topic_for_approve
    if forum_topic
      forum_topic.posts.create(
        :body => "The tag implication #{antecedent_name} -> #{consequent_name} has been approved."
      )
    end
  end

  def update_forum_topic_for_reject
    if forum_topic
      forum_topic.posts.create(
        :body => "The tag implication #{antecedent_name} -> #{consequent_name} has been rejected."
      )
    end
  end

  def update_forum_topic_for_error(e)
    if forum_topic
      forum_topic.posts.create(
        :body => "The tag implication #{antecedent_name} -> #{consequent_name} failed during processing. Reason: #{e}"
      )
    end
  end

  def wiki_pages_present
    return if skip_secondary_validations

    unless WikiPage.titled(consequent_name).exists?
      self.errors[:base] = "The #{consequent_name} tag needs a corresponding wiki page"
      return false
    end

    unless WikiPage.titled(antecedent_name).exists?
      self.errors[:base] = "The #{antecedent_name} tag needs a corresponding wiki page"
      return false
    end
  end

  def approve!(approver_id)
    self.status = "queued"
    self.approver_id = approver_id
    save
    delay(:queue => "default").process!(true)
  end

  def reject!
    update_forum_topic_for_reject
    destroy
  end
end
