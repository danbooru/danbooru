class TagImplication < ActiveRecord::Base
  attr_accessor :skip_secondary_validations

  before_save :update_descendant_names
  after_save :update_descendant_names_for_parents
  after_destroy :update_descendant_names_for_parents
  after_save :create_mod_action
  belongs_to :creator, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :forum_topic
  belongs_to :forum_post
  before_validation :initialize_creator, :on => :create
  before_validation :normalize_names
  validates_format_of :status, :with => /\A(active|deleted|pending|processing|queued|error: .*)\Z/
  validates_presence_of :creator_id, :antecedent_name, :consequent_name
  validates :creator, presence: { message: "must exist" }, if: lambda { creator_id.present? }
  validates :approver, presence: { message: "must exist" }, if: lambda { approver_id.present? }
  validates :forum_topic, presence: { message: "must exist" }, if: lambda { forum_topic_id.present? }
  validates_uniqueness_of :antecedent_name, :scope => :consequent_name
  validate :absence_of_circular_relation
  validate :antecedent_is_not_aliased
  validate :consequent_is_not_aliased
  validate :antecedent_and_consequent_are_different
  validate :wiki_pages_present, :on => :create
  attr_accessible :antecedent_name, :consequent_name, :forum_topic_id, :skip_secondary_validations
  attr_accessible :status, :approver_id, :as => [:admin]

  module DescendantMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # assumes names are normalized
      def with_descendants(names)
        (names + where("antecedent_name in (?) and status in (?)", names, ["active", "processing"]).map(&:descendant_names_array)).flatten.uniq
      end

      def automatic_tags_for(names)
        tags = names.grep(/\A(.+)_\(cosplay\)\Z/) { $1 }
        tags << "cosplay" if tags.present?
        tags.uniq
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
      update({ :descendant_names => descendant_names }, :as => CurrentUser.role)
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

  module ValidationMethods
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
  end

  module ApprovalMethods
    def process!(update_topic: true)
      unless valid?
        raise errors.full_messages.join("; ")
      end

      tries = 0

      begin
        CurrentUser.scoped(approver) do
          update({ :status => "processing" }, :as => CurrentUser.role)
          update_posts
          update({ :status => "active" }, :as => CurrentUser.role)
          update_descendant_names_for_parents
          forum_updater.update("The tag implication #{antecedent_name} -> #{consequent_name} has been approved.", "APPROVED") if update_topic
        end
      rescue Exception => e
        if tries < 5
          tries += 1
          sleep 2 ** tries
          retry
        end

        forum_updater.update("The tag implication #{antecedent_name} -> #{consequent_name} failed during processing. Reason: #{e}", "FAILED") if update_topic
        update({ :status => "error: #{e}" }, :as => CurrentUser.role)

        if Rails.env.production?
          NewRelic::Agent.notice_error(e, :custom_params => {:tag_implication_id => id, :antecedent_name => antecedent_name, :consequent_name => consequent_name})
        end
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

    def approve!(approver: CurrentUser.user, update_topic: true)
      update({ :status => "queued", :approver_id => approver.id }, :as => approver.role)
      delay(:queue => "default").process!(update_topic: update_topic)
    end

    def reject!
      update({ :status => "deleted", }, :as => CurrentUser.role)
      forum_updater.update("The tag implication #{antecedent_name} -> #{consequent_name} has been rejected.", "REJECTED")
      destroy
    end

    def create_mod_action
      implication = %Q("tag implication ##{id}":[#{Rails.application.routes.url_helpers.tag_implication_path(self)}]: [[#{antecedent_name}]] -> [[#{consequent_name}]])

      if id_changed?
        ModAction.log("created #{status} #{implication}")
      else
        # format the changes hash more nicely.
        change_desc = changes.except(:updated_at).map do |attribute, values|
          old, new = values[0], values[1]
          if old.nil?
            %Q(set #{attribute} to "#{new}")
          else
            %Q(changed #{attribute} from "#{old}" to "#{new}")
          end
        end.join(", ")

        ModAction.log("updated #{implication}\n#{change_desc}")
      end
    end

    def date_timestamp
      Time.now.strftime("%Y-%m-%d")
    end

    def forum_updater
      @forum_updater ||= begin
        post = if forum_topic
          forum_post || forum_topic.posts.where("body like ?", TagImplicationRequest.command_string(antecedent_name, consequent_name) + "%").last
        else
          nil
        end
        ForumUpdater.new(
          forum_topic, 
          forum_post: post, 
          expected_title: TagImplicationRequest.topic_title(antecedent_name, consequent_name)
        )
      end
    end
  end

  include DescendantMethods
  include ParentMethods
  extend SearchMethods
  include ValidationMethods
  include ApprovalMethods

  def initialize_creator
    self.creator_id = CurrentUser.user.id
    self.creator_ip_addr = CurrentUser.ip_addr
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
end
