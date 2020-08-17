class PostDisapproval < ApplicationRecord
  DELETION_THRESHOLD = 1.month
  REASONS = %w[breaks_rules poor_quality disinterest]

  belongs_to :post
  belongs_to :user
  validates :user, uniqueness: { scope: :post, message: "have already hidden this post" }
  validates_inclusion_of :reason, in: REASONS
  validate :validate_disapproval

  scope :with_message, -> { where.not(message: nil) }
  scope :without_message, -> { where(message: nil) }
  scope :breaks_rules, -> {where(:reason => "breaks_rules")}
  scope :poor_quality, -> {where(:reason => "poor_quality")}
  scope :disinterest, -> {where(:reason => "disinterest")}

  def self.prune!
    PostDisapproval.where("post_id in (select _.post_id from post_disapprovals _ where _.created_at < ?)", DELETION_THRESHOLD.ago).delete_all
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = super

        q = q.search_attributes(params, :message, :reason)
        q = q.text_attribute_matches(:message, params[:message_matches])

        q = q.with_message if params[:has_message].to_s.truthy?
        q = q.without_message if params[:has_message].to_s.falsy?

        case params[:order]
        when "post_id", "post_id_desc"
          q = q.order(post_id: :desc, id: :desc)
        else
          q = q.apply_default_order(params)
        end

        q
      end
    end
  end

  def self.searchable_includes
    [:user, :post]
  end

  def self.available_includes
    [:user, :post]
  end

  def validate_disapproval
    if post.is_active?
      errors[:post] << "is already active and cannot be disapproved"
    end
  end

  def message=(message)
    message = nil if message.blank?
    super(message)
  end
end
