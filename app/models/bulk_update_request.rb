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

  normalizes :script, with: ->(script) { script.to_s.unicode_normalize(:nfc).normalize_whitespace.strip }

  # XXX these validations must match the forum post validations
  validates :reason, visible_string: true, length: { maximum: 20_000 }, on: :create
  validates :title, visible_string: true, length: { maximum: 200 }, on: :create, if: ->(bur) { bur.forum_topic_id.blank? }

  validates :script, visible_string: true, length: { maximum: 20_000 }, if: :script_changed?
  validates :forum_topic, presence: true, if: ->(bur) { bur.forum_topic_id.present? }
  validates :forum_post, presence: true, if: ->(bur) { bur.forum_post_id.present? }
  validates :status, inclusion: { in: STATUSES }
  validate :validate_script, if: :script_changed?
  validates_associated :forum_topic, if: :forum_topic_changed?
  validates_associated :forum_post, if: :forum_post_changed?

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

      if params[:status].present?
        q = q.where(status: params[:status].split(","))
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
          processor.validate!(:approval)
          update!(status: "processing", approver: approver)
          processor.process_later!
          forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has been approved by @#{approver.name}.") if forum_post.present?
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

  extend SearchMethods
  include ApprovalMethods

  def update_tags
    self.tags = processor.affected_tags
  end

  def processor
    @processor ||= BulkUpdateRequestProcessor.new(self)
  end

  def is_tag_move_allowed?
    processor.is_tag_move_allowed?
  end

  def has_too_many_votes_to_edit?
    (forum_post&.votes&.count.presence || 0) >= 5
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
