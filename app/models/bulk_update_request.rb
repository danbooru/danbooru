# frozen_string_literal: true

class BulkUpdateRequest < ApplicationRecord
  STATUSES = %w[pending approved rejected processing failed]

  attr_accessor :title, :reason

  belongs_to :user
  belongs_to :forum_topic, optional: true
  belongs_to :forum_post, optional: true
  belongs_to :approver, optional: true, class_name: "User"

  validates :reason, presence: true, on: :create
  validates :script, presence: true
  validates :title, presence: true, if: ->(rec) { rec.forum_topic_id.blank? }
  validates :forum_topic, presence: true, if: ->(rec) { rec.forum_topic_id.present? }
  validates :status, inclusion: { in: STATUSES }
  validate :validate_script, if: :script_changed?

  before_save :update_tags, if: :script_changed?
  after_create :create_forum_topic

  scope :pending_first, -> { order(Arel.sql("(case status when 'processing' then 0 when 'pending' then 1 when 'approved' then 2 when 'rejected' then 3 when 'failed' then 4 else 5 end)")) }
  scope :pending, -> {where(status: "pending")}
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :processing, -> { where(status: "processing") }
  scope :failed, -> { where(status: "failed") }
  scope :has_topic, -> { where.not(forum_topic: nil) }

  module SearchMethods
    def search(params = {})
      q = search_attributes(params, :id, :created_at, :updated_at, :script, :tags, :user, :forum_topic, :forum_post, :approver)

      if params[:status].present?
        q = q.where(status: params[:status].split(","))
      end

      params[:order] ||= "status_desc"
      case params[:order]
      when "id_desc"
        q = q.order(id: :desc)
      when "id_asc"
        q = q.order(id: :asc)
      when "updated_at_desc"
        q = q.order(updated_at: :desc)
      when "updated_at_asc"
        q = q.order(updated_at: :asc)
      else
        q = q.apply_default_order(params)
      end

      q
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
          forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has been approved by @#{approver.name}.")
        end
      end
    end

    def create_forum_topic
      CurrentUser.scoped(user) do
        body = "[bur:#{id}]\n\n#{reason}"
        self.forum_topic = ForumTopic.create(title: title, category_id: 1, creator: user) unless forum_topic.present?
        self.forum_post = forum_topic.forum_posts.create(body: body, creator: user) unless forum_post.present?
        save
      end
    end

    def reject!(rejector = User.system)
      transaction do
        update!(status: "rejected")
        forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has been rejected by @#{rejector.name}.")
      end
    end

    def bulk_update_request_link
      %{"bulk update request ##{id}":#{Routes.bulk_update_requests_path(search: { id: id })}}
    end
  end

  def validate_script
    if processor.invalid?(:request)
      errors.add(:base, processor.errors.full_messages.join("; "))
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
