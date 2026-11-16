# frozen_string_literal: true

class BulkUpdateRequest < ApplicationRecord
  STATUSES = %w[pending approved rejected processing failed]

  attr_accessor :title, :reason

  # defines :dtext_reason
  # XXX media embed validations must match forum post validations
  dtext_attribute :reason, media_embeds: { max_embeds: 5, max_large_emojis: 5, max_small_emojis: 100, max_video_size: 1.megabyte, sfw_only: true }

  belongs_to :user
  belongs_to :forum_topic, optional: true
  belongs_to :forum_post, optional: true
  belongs_to :approver, optional: true, class_name: "User"

  has_many :votes, through: :forum_post

  delegate :approval_level, to: :processor

  normalizes :script, with: ->(script) { script.to_s.unicode_normalize(:nfc).normalize_whitespace.strip }

  # XXX these validations must match the forum post validations
  validates :reason, visible_string: true, length: { maximum: 20_000 }, on: :create
  validates :title, visible_string: true, length: { maximum: 200 }, on: :create, if: ->(bur) { bur.forum_topic_id.blank? }

  validates :script, visible_string: true, length: { maximum: 20_000 }, if: :script_changed?
  validates :forum_topic, presence: true, if: ->(bur) { bur.forum_topic_id.present? }
  validates :forum_post, presence: true, if: ->(bur) { bur.forum_post_id.present? }
  validates :status, inclusion: { in: STATUSES }
  validate :validate_script, if: :script_changed?
  validate :validate_approval, on: :approval
  validate :validate_forum_topic, if: :forum_topic_changed?
  validate :validate_forum_post, if: :forum_post_changed?

  before_save :update_tags, if: :script_changed?
  after_create :create_forum_topic

  scope :pending_first, -> { order(Arel.sql("(case status when 'processing' then 0 when 'pending' then 1 when 'approved' then 2 when 'rejected' then 3 when 'failed' then 4 else 5 end)")) }
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :processing, -> { where(status: "processing") }
  scope :failed, -> { where(status: "failed") }
  scope :has_topic, -> { where.not(forum_topic: nil) }

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :script, :tags, :user, :forum_topic, :forum_post, :approver], current_user: current_user)

      statuses = params[:status].to_s.split(",")

      if statuses.present?
        q = q.where(status: statuses)
      end

      if params[:can_approve].present? && statuses.present? && statuses.exclude?("pending")
        q = q.none
      elsif params[:can_approve].present?
        can_approve = params[:can_approve].to_s.truthy?
        tags = Tag.where(name: q.pending.select(Arel.sql("unnest(tags)"))).to_a

        ids = q.pending.select { |bur| Pundit.policy!(current_user, bur).approve?(tags:) == can_approve }.map(&:id)
        q = q.where(id: ids)
      end

      params[:order] ||= "status_desc"

      if params[:score].present? || params[:order].in?(%w[score score_desc score_asc])
        q = q.with_score
      end

      if params[:score].present?
        q = q.where_numeric_matches(:score, params[:score])
      end

      case params[:order]
      when "id_desc"
        q = q.order(id: :desc)
      when "id_asc"
        q = q.order(id: :asc)
      when "updated_at_desc"
        q = q.order(updated_at: :desc)
      when "updated_at_asc"
        q = q.order(updated_at: :asc)
      when "score", "score_desc"
        q = q.order(score: :desc, id: :desc)
      when "score_asc"
        q = q.order(score: :asc, id: :desc)
      else
        q = q.apply_default_order(params)
      end

      q
    end

    def with_score
      subquery = left_outer_joins(:votes).group(:id).select("bulk_update_requests.*")
      subquery = subquery.select("COALESCE(SUM(forum_post_votes.score), 0) AS score")
      from(subquery.arel.as("bulk_update_requests"))
    end
  end

  module ApprovalMethods
    def forum_updater
      @forum_updater ||= ForumUpdater.new(forum_topic)
    end

    def approve!(approver)
      transaction do
        CurrentUser.scoped(approver) do
          self.approver = approver
          self.status = "processing"

          if save(context: :approval)
            processor.process_later!
            forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has been approved by @#{approver.name}.") if forum_post.present?
          end
        end
      end
    end

    def create_forum_topic
      body = "[bur:#{id}]\n\n#{reason}"

      self.forum_topic = ForumTopic.new(title: title, category: "Tags", creator: user) unless forum_topic.present?
      self.forum_post = forum_topic.forum_posts.build(body: body, creator: user) unless forum_post.present?

      save!
    end

    def reject!(rejector = User.system)
      transaction do
        update!(status: "rejected")
        forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has been rejected by @#{rejector.name}.") if forum_post.present?
      end
    end

    def bulk_update_request_link
      %{"bulk update request ##{id}":#{Routes.bulk_update_requests_path(search: { id: id })}}
    end
  end

  def validate_script
    if processor.invalid?(:request)
      processor.errors.full_messages.each { |error| errors.add(:base, error) }
    end
  end

  def validate_approval
    # The approval checks look at the tags' current state, but an approved BUR that hasn't been processed yet can still
    # change it (e.g. `imply a -> b` before `alias a -> big_tag`).
    processing_bur = BulkUpdateRequest.where(status: "processing").where.not(id: id).where_array_includes_any(:tags, tags).first

    if processing_bur.present?
      errors.add(:base, "Can't approve this request while BUR ##{processing_bur.id} is still being processed")
    elsif processor.invalid?(:approval)
      processor.errors.full_messages.each { |error| errors.add(:base, error) }
    end
  end

  extend SearchMethods
  include ApprovalMethods

  # Show the topic's errors instead of "Forum topic is invalid". If the forum post is being created too, the errors from
  # the topic's posts are shown by `validate_forum_post` instead.
  def validate_forum_topic
    return if forum_topic.nil? || forum_topic.valid?

    topic_errors = forum_topic.errors.reject { |error| error.attribute == :forum_posts && forum_post_changed? }
    topic_errors.each { |error| errors.add(:base, error.full_message) }
  end

  # Show the forum post's errors instead of "Forum post is invalid". Errors in the post's body are errors in the reason.
  def validate_forum_post
    return if forum_post.nil? || forum_post.valid?

    forum_post.errors.each do |error|
      if error.attribute == :body
        errors.add(:reason, error.message)
      else
        errors.add(:base, error.full_message)
      end
    end
  end

  def update_tags
    self.tags = processor.affected_tags
  end

  def processor
    @processor ||= BulkUpdateRequest::Processor.new(self)
  end

  def has_too_many_votes_to_edit?
    (forum_post&.votes&.size.presence || 0) >= 5
  end

  def is_pending?
    status == "pending"
  end

  def is_approved?
    status.in?(%w[approved processing])
  end

  def is_rejected?
    status == "rejected"
  end

  def self.available_includes
    [:user, :forum_topic, :forum_post, :approver]
  end
end
