class TagImplication < TagRelationship
  before_save :update_descendant_names
  after_save :update_descendant_names_for_parents
  after_destroy :update_descendant_names_for_parents
  after_save :update_descendant_names_for_parents, if: ->(rec) { rec.is_retired? }
  after_save :create_mod_action
  validates_uniqueness_of :antecedent_name, :scope => :consequent_name
  validate :absence_of_circular_relation
  validate :absence_of_transitive_relation
  validate :antecedent_is_not_aliased
  validate :consequent_is_not_aliased
  validate :antecedent_and_consequent_are_different
  validate :wiki_pages_present, :on => :create
  scope :expired, ->{where("created_at < ?", 2.months.ago)}
  scope :old, ->{where("created_at between ? and ?", 2.months.ago, 1.month.ago)}
  scope :pending, ->{where(status: "pending")}

  module DescendantMethods
    extend ActiveSupport::Concern

    module ClassMethods
      # assumes names are normalized
      def with_descendants(names)
        (names + active.where(antecedent_name: names).flat_map(&:descendant_names_array)).uniq
      end

      def automatic_tags_for(names)
        tags = names.grep(/\A(.+)_\(cosplay\)\Z/) { "char:#{TagAlias.to_aliased([$1]).first}" }
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
            children = TagImplication.active.where(antecedent_name: children).pluck(:consequent_name)
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
      update_attribute(:descendant_names, descendant_names)
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

  module ValidationMethods
    def absence_of_circular_relation
      # We don't want a -> b && b -> a chains
      if self.class.active.exists?(["antecedent_name = ? and consequent_name = ?", consequent_name, antecedent_name])
        self.errors[:base] << "Tag implication can not create a circular relation with another tag implication"
        false
      end
    end

    # If we already have a -> b -> c, don't allow a -> c.
    def absence_of_transitive_relation
      # Find everything else the antecedent implies, not including the current implication.
      implications = TagImplication.active.where("antecedent_name = ? and consequent_name != ?", antecedent_name, consequent_name)
      implied_tags = implications.flat_map(&:descendant_names_array)
      if implied_tags.include?(consequent_name)
        self.errors[:base] << "#{antecedent_name} already implies #{consequent_name} through another implication"
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
        self.errors[:base] << "The #{consequent_name} tag needs a corresponding wiki page"
        return false
      end

      unless WikiPage.titled(antecedent_name).exists?
        self.errors[:base] << "The #{antecedent_name} tag needs a corresponding wiki page"
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
          update(status: "processing")
          update_posts
          update(status: "active")
          update_descendant_names_for_parents
          forum_updater.update(approval_message(approver), "APPROVED") if update_topic
        end
      rescue Exception => e
        if tries < 5
          tries += 1
          sleep 2 ** tries
          retry
        end

        forum_updater.update(failure_message(e), "FAILED") if update_topic
        update(status: "error: #{e}")

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
      update(status: "queued", approver_id: approver.id)
      delay(:queue => "default").process!(update_topic: update_topic)
    end

    def reject!
      update(status: "deleted")
      forum_updater.update(reject_message(CurrentUser.user), "REJECTED")
      destroy
    end

    def create_mod_action
      implication = %Q("tag implication ##{id}":[#{Rails.application.routes.url_helpers.tag_implication_path(self)}]: [[#{antecedent_name}]] -> [[#{consequent_name}]])

      if saved_change_to_id?
        ModAction.log("created #{status} #{implication}",:tag_implication_create)
      else
        # format the changes hash more nicely.
        change_desc = saved_changes.except(:updated_at).map do |attribute, values|
          old, new = values[0], values[1]
          if old.nil?
            %Q(set #{attribute} to "#{new}")
          else
            %Q(changed #{attribute} from "#{old}" to "#{new}")
          end
        end.join(", ")

        ModAction.log("updated #{implication}\n#{change_desc}",:tag_implication_update)
      end
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
  include ValidationMethods
  include ApprovalMethods

  def reload(options = {})
    super
    clear_parents_cache
    clear_descendants_cache
  end
end
