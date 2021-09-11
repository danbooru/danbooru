class TagRelationship < ApplicationRecord
  self.abstract_class = true

  belongs_to :creator, class_name: "User"
  belongs_to :approver, class_name: "User", optional: true
  belongs_to :forum_post, optional: true
  belongs_to :forum_topic, optional: true
  belongs_to :antecedent_tag, class_name: "Tag", foreign_key: "antecedent_name", primary_key: "name", default: -> { Tag.find_or_create_by_name(antecedent_name) }
  belongs_to :consequent_tag, class_name: "Tag", foreign_key: "consequent_name", primary_key: "name", default: -> { Tag.find_or_create_by_name(consequent_name) }
  belongs_to :antecedent_wiki, class_name: "WikiPage", foreign_key: "antecedent_name", primary_key: "title", optional: true
  belongs_to :consequent_wiki, class_name: "WikiPage", foreign_key: "consequent_name", primary_key: "title", optional: true

  scope :active, -> {where(status: "active")}
  scope :deleted, -> {where(status: "deleted")}
  scope :retired, -> {where(status: "retired")}

  before_validation :normalize_names
  validates :status, inclusion: { in: %w[active deleted retired] }
  validates :antecedent_name, presence: true
  validates :consequent_name, presence: true
  validates :approver, presence: { message: "must exist" }, if: -> { approver_id.present? }
  validates :forum_topic, presence: { message: "must exist" }, if: -> { forum_topic_id.present? }
  validate :antecedent_and_consequent_are_different

  def normalize_names
    self.antecedent_name = antecedent_name.mb_chars.downcase.tr(" ", "_")
    self.consequent_name = consequent_name.mb_chars.downcase.tr(" ", "_")
  end

  def is_rejected?
    status.in?(%w[retired deleted])
  end

  def is_retired?
    status == "retired"
  end

  def is_deleted?
    status == "deleted"
  end

  def is_active?
    status == "active"
  end

  # Mark an alias or implication as deleted, and log a mod action if the
  # deletion was manually performed by an admin, as opposed to automatically by
  # DanbooruBot as part of a BUR.
  def reject!(rejector = CurrentUser.user)
    update!(status: "deleted")

    if rejector != User.system
      category = relationship == "tag alias" ? :tag_alias_delete : :tag_implication_delete
      ModAction.log("deleted #{relationship} #{antecedent_name} -> #{consequent_name}", category, rejector)
    end
  end

  module SearchMethods
    def name_matches(name)
      where_ilike(:antecedent_name, name).or(where_ilike(:consequent_name, name))
    end

    def status_matches(status)
      where(status: status.downcase)
    end

    def search(params)
      q = search_attributes(params, :id, :created_at, :updated_at, :antecedent_name, :consequent_name, :reason, :creator, :approver, :forum_post, :forum_topic, :antecedent_tag, :consequent_tag, :antecedent_wiki, :consequent_wiki)

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:status].present?
        q = q.status_matches(params[:status])
      end

      if params[:category].present?
        q = q.joins(:consequent_tag).where("tags.category": params[:category].split)
      end

      case params[:order].to_s.downcase
      when "created_at"
        q = q.order("created_at desc")
      when "updated_at"
        q = q.order("updated_at desc")
      when "name"
        q = q.order("antecedent_name asc, consequent_name asc")
      when "tag_count"
        q = q.joins(:consequent_tag).order("tags.post_count desc, antecedent_name asc, consequent_name asc")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  module MessageMethods
    def relationship
      # "TagAlias" -> "tag alias", "TagImplication" -> "tag implication"
      self.class.name.underscore.tr("_", " ")
    end

    def retirement_message
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] has been retired."
    end
  end

  def antecedent_and_consequent_are_different
    if antecedent_name == consequent_name
      errors.add(:base, "Cannot alias or implicate a tag to itself")
    end
  end

  def self.approve!(antecedent_name:, consequent_name:, approver:, forum_topic: nil)
    ProcessTagRelationshipJob.perform_later(class_name: name, approver: approver, antecedent_name: antecedent_name, consequent_name: consequent_name, forum_topic: forum_topic)
  end

  def self.model_restriction(table)
    super.where(table[:status].eq("active"))
  end

  def self.available_includes
    [:creator, :approver, :forum_post, :forum_topic, :antecedent_tag, :consequent_tag, :antecedent_wiki, :consequent_wiki]
  end

  extend SearchMethods
  include MessageMethods
end
