# frozen_string_literal: true

class ModerationReport < ApplicationRecord
  MODEL_TYPES = %w[Dmail Comment ForumPost]

  attr_accessor :updater

  belongs_to :model, polymorphic: true
  belongs_to :creator, class_name: "User"
  has_many :mod_actions, as: :subject, dependent: :destroy

  before_validation(on: :create) { model.lock! }
  validates :reason, presence: true
  validates :model_type, inclusion: { in: MODEL_TYPES }
  validates :creator, uniqueness: { scope: [:model_type, :model_id], message: "have already reported this message." }, on: :create

  after_create :autoban_reported_user
  after_save :notify_reporter
  after_save :create_modaction

  scope :dmail, -> { where(model_type: "Dmail") }
  scope :comment, -> { where(model_type: "Comment") }
  scope :forum_post, -> { where(model_type: "ForumPost") }
  scope :recent, -> { where("moderation_reports.created_at >= ?", 1.week.ago) }

  enum status: {
    pending: 0,
    rejected: 1,
    handled: 2,
  }

  def self.model_types
    MODEL_TYPES
  end

  def self.visible(user)
    if user.is_moderator?
      all
    elsif !user.is_anonymous?
      where(creator: user)
    else
      none
    end
  end

  def autoban_reported_user
    if SpamDetector.is_spammer?(reported_user)
      SpamDetector.ban_spammer!(reported_user)
    end
  end

  def notify_reporter
    return if creator == User.system
    return unless handled? && status_before_last_save != :handled

    Dmail.create_automated(to: creator, title: "Thank you for reporting #{model.dtext_shortlink}", body: <<~EOS)
      Thank you for reporting #{model.dtext_shortlink}. Action has been taken against the user.
    EOS
  end

  def create_modaction
    return unless saved_change_to_status? && status != :pending

    if handled?
      ModAction.log("handled modreport ##{id}", :moderation_report_handled, subject: self, user: updater)
    elsif rejected?
      ModAction.log("rejected modreport ##{id}", :moderation_report_rejected, subject: self, user: updater)
    end
  end

  def reported_user
    case model
    when Comment, ForumPost
      model.creator
    when Dmail
      model.from
    else
      raise NotImplementedError
    end
  end

  def self.received_by(user)
    where(model: Comment.where(creator: user)).or(where(model: ForumPost.where(creator: user))).or(where(model: Dmail.received.where(from: user)))
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :reason, :creator, :model, :status], current_user: current_user)

    if params[:recipient_id].present?
      q = q.received_by(User.search({ id: params[:recipient_id] }, current_user))
    elsif params[:recipient_name].present?
      q = q.received_by(User.search({ name_matches: params[:recipient_name] }, current_user))
    end

    q.apply_default_order(params)
  end

  def self.available_includes
    [:creator, :model]
  end
end
