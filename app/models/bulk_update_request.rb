class BulkUpdateRequest < ApplicationRecord
  attr_accessor :title
  attr_accessor :reason
  attr_reader :skip_secondary_validations

  belongs_to :user
  belongs_to :forum_topic, optional: true
  belongs_to :forum_post, optional: true
  belongs_to :approver, optional: true, class_name: "User"

  validates_presence_of :reason, on: :create
  validates_presence_of :script
  validates_presence_of :title, if: ->(rec) {rec.forum_topic_id.blank?}
  validates_presence_of :forum_topic, if: ->(rec) {rec.forum_topic_id.present?}
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  validate :validate_script, if: :script_changed?

  before_save :update_tags, if: :script_changed?
  after_create :create_forum_topic

  scope :pending_first, -> { order(Arel.sql("(case status when 'pending' then 0 when 'approved' then 1 else 2 end)")) }
  scope :pending, -> {where(status: "pending")}
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }
  scope :has_topic, -> { where.not(forum_topic: nil) }
  scope :expired, -> {where("created_at < ?", TagRelationship::EXPIRY.days.ago)}
  scope :old, -> {where("created_at between ? and ?", TagRelationship::EXPIRY.days.ago, TagRelationship::EXPIRY_WARNING.days.ago)}

  module SearchMethods
    def default_order
      pending_first.order(id: :desc)
    end

    def search(params = {})
      q = super

      q = q.search_attributes(params, :script, :tags)
      q = q.text_attribute_matches(:script, params[:script_matches])

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
      @forum_updater ||= begin
        post = if forum_topic
          forum_post || forum_topic.forum_posts.first
        else
          nil
        end
        ForumUpdater.new(forum_topic, forum_post: post)
      end
    end

    def approve!(approver)
      transaction do
        CurrentUser.scoped(approver) do
          processor.process!(approver)
          update!(status: "approved", approver: approver, skip_secondary_validations: true)
          forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has been approved by @#{approver.name}.")
        end
      end
    rescue BulkUpdateRequestProcessor::Error => x
      self.approver = approver
      CurrentUser.scoped(approver) do
        forum_updater.update("The #{bulk_update_request_link} (forum ##{forum_post.id}) has failed: #{x}")
      end
    end

    def create_forum_topic
      CurrentUser.as(user) do
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
      %{"bulk update request ##{id}":/bulk_update_requests?search%5Bid%5D=#{id}}
    end
  end

  def validate_script
    if processor.invalid?
      errors[:base] << processor.errors.full_messages.join("; ")
    end
  end

  extend SearchMethods
  include ApprovalMethods

  def update_tags
    self.tags = processor.affected_tags
  end

  def skip_secondary_validations=(v)
    @skip_secondary_validations = v.to_s.truthy?
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
    status == "approved"
  end

  def is_rejected?
    status == "rejected"
  end

  def self.searchable_includes
    [:user, :forum_topic, :forum_post, :approver]
  end

  def self.available_includes
    [:user, :forum_topic, :forum_post, :approver]
  end
end
