class TagRelationship < ApplicationRecord
  self.abstract_class = true

  SUPPORT_HARD_CODED = true
  EXPIRY = 60
  EXPIRY_WARNING = 55

  attr_accessor :skip_secondary_validations

  belongs_to :creator, class_name: "User"
  belongs_to :approver, class_name: "User", optional: true
  belongs_to :forum_post, optional: true
  belongs_to :forum_topic, optional: true
  belongs_to :antecedent_tag, class_name: "Tag", foreign_key: "antecedent_name", primary_key: "name", default: -> { Tag.find_or_create_by_name(antecedent_name) }
  belongs_to :consequent_tag, class_name: "Tag", foreign_key: "consequent_name", primary_key: "name", default: -> { Tag.find_or_create_by_name(consequent_name) }
  has_one :antecedent_wiki, through: :antecedent_tag, source: :wiki_page
  has_one :consequent_wiki, through: :consequent_tag, source: :wiki_page

  scope :active, -> {approved}
  scope :approved, -> {where(status: %w[active processing queued])}
  scope :deleted, -> {where(status: "deleted")}
  scope :expired, -> {where("created_at < ?", EXPIRY.days.ago)}
  scope :old, -> {where("created_at >= ? and created_at < ?", EXPIRY.days.ago, EXPIRY_WARNING.days.ago)}
  scope :pending, -> {where(status: "pending")}
  scope :retired, -> {where(status: "retired")}

  before_validation :normalize_names
  validates_format_of :status, :with => /\A(active|deleted|pending|processing|queued|retired|error: .*)\Z/
  validates_presence_of :antecedent_name, :consequent_name
  validates :approver, presence: { message: "must exist" }, if: -> { approver_id.present? }
  validates :forum_topic, presence: { message: "must exist" }, if: -> { forum_topic_id.present? }
  validate :antecedent_and_consequent_are_different
  after_save :update_notice

  def normalize_names
    self.antecedent_name = antecedent_name.mb_chars.downcase.tr(" ", "_")
    self.consequent_name = consequent_name.mb_chars.downcase.tr(" ", "_")
  end

  def is_approved?
    status.in?(%w[active processing queued])
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

  def is_pending?
    status == "pending"
  end

  def is_active?
    status == "active"
  end

  def is_errored?
    status =~ /\Aerror:/
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

  def reject!(update_topic: true)
    transaction do
      update!(status: "deleted")
      forum_updater.update(reject_message(CurrentUser.user), "REJECTED") if update_topic
    end
  end

  module SearchMethods
    def name_matches(name)
      where_ilike(:antecedent_name, name).or(where_ilike(:consequent_name, name))
    end

    def status_matches(status)
      status = status.downcase

      if status == "approved"
        where(status: %w[active processing queued])
      else
        where(status: status)
      end
    end

    def tag_matches(field, params)
      return all if params.blank?
      where(field => Tag.search(params).reorder(nil).select(:name))
    end

    def pending_first
      # unknown statuses return null and are sorted first
      order(Arel.sql("array_position(array['queued', 'processing', 'pending', 'active', 'deleted', 'retired'], status::text) NULLS FIRST, antecedent_name, consequent_name"))
    end

    def default_order
      pending_first
    end

    def search(params)
      q = super
      q = q.search_attributes(params, :creator, :approver, :forum_topic_id, :forum_post_id, :antecedent_name, :consequent_name)

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:status].present?
        q = q.status_matches(params[:status])
      end

      q = q.tag_matches(:antecedent_name, params[:antecedent_tag])
      q = q.tag_matches(:consequent_name, params[:consequent_tag])

      if params[:category].present?
        q = q.joins(:consequent_tag).where("tags.category": params[:category].split)
      end

      params[:order] ||= "status"
      case params[:order].downcase
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

    def approval_message(approver)
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has been approved by @#{approver.name}."
    end

    def failure_message(e = nil)
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} failed during processing. Reason: #{e}"
    end

    def reject_message(rejector)
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has been rejected by @#{rejector.name}."
    end

    def retirement_message
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has been retired."
    end

    def conflict_message
      "The tag alias [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has conflicting wiki pages. [[#{consequent_name}]] should be updated to include information from [[#{antecedent_name}]] if necessary."
    end

    def date_timestamp
      Time.now.strftime("%Y-%m-%d")
    end

    def forum_link
      "(forum ##{forum_post.id})" if forum_post.present?
    end
  end

  concerning :EmbeddedText do
    class_methods do
      def embedded_pattern
        raise NotImplementedError
      end
    end
  end

  def antecedent_and_consequent_are_different
    if antecedent_name == consequent_name
      errors[:base] << "Cannot alias or implicate a tag to itself"
    end
  end

  def estimate_update_count
    Post.fast_count(antecedent_name, skip_cache: true)
  end

  def update_posts
    Post.without_timeout do
      Post.raw_tag_match(antecedent_name).find_each do |post|
        post.with_lock do
          post.save!
        end
      end
    end
  end

  def update_notice
    TagChangeNoticeService.update_cache(
      [antecedent_name, consequent_name],
      forum_topic_id
    )
  end

  def self.available_includes
    [:creator, :approver, :forum_post, :forum_topic, :antecedent_tag, :consequent_tag, :antecedent_wiki, :consequent_wiki]
  end

  extend SearchMethods
  include MessageMethods
end
