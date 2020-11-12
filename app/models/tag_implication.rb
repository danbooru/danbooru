class TagImplication < TagRelationship
  has_many :child_implications, class_name: "TagImplication", primary_key: :consequent_name, foreign_key: :antecedent_name
  has_many :parent_implications, class_name: "TagImplication", primary_key: :antecedent_name, foreign_key: :consequent_name

  after_save :create_mod_action
  validates_uniqueness_of :antecedent_name, scope: [:consequent_name, :status], conditions: -> { active }
  validate :absence_of_circular_relation
  validate :absence_of_transitive_relation
  validate :antecedent_is_not_aliased
  validate :consequent_is_not_aliased
  validate :wiki_pages_present, on: :create, unless: :skip_secondary_validations

  module DescendantMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def automatic_tags_for(names)
        tags = []
        tags += names.grep(/\A(.+)_\(cosplay\)\z/i) { "char:#{TagAlias.to_aliased([$1]).first}" }
        tags << "cosplay" if names.any?(/_\(cosplay\)\z/i)
        tags << "school_uniform" if names.any?(/_school_uniform\z/i)
        tags.uniq
      end
    end
  end

  concerning :HierarchyMethods do
    class_methods do
      def ancestors_of(names)
        join_recursive do |query|
          query.start_with(antecedent_name: names).connect_by(consequent_name: :antecedent_name)
        end
      end

      def descendants_of(names)
        join_recursive do |query|
          query.start_with(consequent_name: names).connect_by(antecedent_name: :consequent_name)
        end
      end

      def tags_implied_by(names)
        Tag.where(name: active.ancestors_of(names).select(:consequent_name)).where.not(name: names)
      end

      def tags_implied_to(names)
        Tag.where(name: active.descendants_of(names).select(:antecedent_name))
      end
    end
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = super

        if params[:implied_from].present?
          q = q.where(id: ancestors_of(params[:implied_from]).select(:id))
        end

        if params[:implied_to].present?
          q = q.where(id: descendants_of(params[:implied_to]).select(:id))
        end

        q
      end
    end
  end

  module ValidationMethods
    def absence_of_circular_relation
      return if is_rejected?

      # We don't want a -> b -> a chains
      implied_tags = TagImplication.tags_implied_by(consequent_name).map(&:name)
      if implied_tags.include?(antecedent_name)
        errors[:base] << "Tag implication can not create a circular relation with another tag implication"
      end
    end

    # If we already have a -> b -> c, don't allow a -> c.
    def absence_of_transitive_relation
      return if is_rejected?

      # Find everything else the antecedent implies, not including the current implication.
      implications = TagImplication.active.where("NOT (tag_implications.antecedent_name = ? AND tag_implications.consequent_name = ?)", antecedent_name, consequent_name)
      implied_tags = implications.tags_implied_by(antecedent_name).map(&:name)

      if implied_tags.include?(consequent_name)
        errors[:base] << "#{antecedent_name} already implies #{consequent_name} through another implication"
      end
    end

    def antecedent_is_not_aliased
      return if is_rejected?

      # We don't want to implicate a -> b if a is already aliased to c
      if TagAlias.active.exists?(["antecedent_name = ?", antecedent_name])
        errors[:base] << "Antecedent tag must not be aliased to another tag"
      end
    end

    def consequent_is_not_aliased
      return if is_rejected?

      # We don't want to implicate a -> b if b is already aliased to c
      if TagAlias.active.exists?(["antecedent_name = ?", consequent_name])
        errors[:base] << "Consequent tag must not be aliased to another tag"
      end
    end

    def wiki_pages_present
      if consequent_wiki.blank?
        errors[:base] << "The #{consequent_name} tag needs a corresponding wiki page"
      end

      if antecedent_wiki.blank?
        errors[:base] << "The #{antecedent_name} tag needs a corresponding wiki page"
      end
    end
  end

  module ApprovalMethods
    def process!(approver)
      unless valid?
        raise errors.full_messages.join("; ")
      end

      CurrentUser.scoped(User.system) do
        update(approver: approver, status: "processing")
        update_posts
        update(status: "active")
      end
    rescue Exception => e
      update(status: "error: #{e}")
      DanbooruLogger.log(e, tag_implication_id: id, antecedent_name: antecedent_name, consequent_name: consequent_name)
    end

    def approve!(approver)
      ProcessTagImplicationJob.perform_later(self, approver)
    end

    def create_mod_action
      implication = %("tag implication ##{id}":[#{Rails.application.routes.url_helpers.tag_implication_path(self)}]: [[#{antecedent_name}]] -> [[#{consequent_name}]])

      if saved_change_to_id?
        ModAction.log("created #{status} #{implication}", :tag_implication_create)
      else
        # format the changes hash more nicely.
        change_desc = saved_changes.except(:updated_at).map do |attribute, values|
          old, new = values[0], values[1]
          if old.nil?
            %(set #{attribute} to "#{new}")
          else
            %(changed #{attribute} from "#{old}" to "#{new}")
          end
        end.join(", ")

        ModAction.log("updated #{implication}\n#{change_desc}", :tag_implication_update)
      end
    end
  end

  include DescendantMethods
  include ValidationMethods
  include ApprovalMethods
end
