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

  def self.dmail_messages!
    disapprovals = PostDisapproval.with_message.where("created_at >= ?", 1.day.ago).group_by do |pd|
      pd.post.uploader
    end

    disapprovals.each do |uploader, list|
      message = list.map do |x|
        "* post ##{x.post_id}: #{x.message}"
      end.join("\n")

      Dmail.create_automated(
        :to_id => uploader.id,
        :title => "Someone has commented on your uploads",
        :body => message
      )
    end
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = super

        q = q.search_attributes(params, :post, :user, :message, :reason)
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

  def self.available_includes
    [:user, :post]
  end

  def validate_disapproval
    if post.status == "active"
      errors[:post] << "is already active and cannot be disapproved"
    end
  end

  def message=(message)
    message = nil if message.blank?
    super(message)
  end

  def api_attributes
    attributes = super
    attributes -= [:creator_id] unless Pundit.policy!([CurrentUser.user, nil], self).can_view_creator?
    attributes
  end
end
