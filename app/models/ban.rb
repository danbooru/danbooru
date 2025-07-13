# frozen_string_literal: true

class Ban < ApplicationRecord
  FOREVER = 100.years
  DURATIONS = [1.day, 3.days, 7.days, 1.month, 3.months, 6.months, 1.year, FOREVER]

  # How far back to delete user data when a ban is created.
  MAX_DELETION_AGE = 3.days

  attr_accessor :updater

  attribute :duration, :interval
  attribute :delete_posts, :boolean
  attribute :post_deletion_reason, :string
  attribute :delete_forum_posts, :boolean
  attribute :delete_comments, :boolean
  attribute :delete_post_votes, :boolean
  attribute :delete_comment_votes, :boolean

  dtext_attribute :reason, inline: true # defines :dtext_reason

  after_create :create_feedback
  after_create :create_dmail
  after_create :delete_user_data
  before_destroy -> { throw :abort if invalid? } # Validations don't run on destroy normally, so we have to do it manually
  after_destroy :create_unban_mod_action
  after_destroy :update_user_on_save
  after_save :create_mod_action
  after_save :update_user_on_save, if: :saved_change_to_duration?

  belongs_to :user
  belongs_to :banner, :class_name => "User"

  normalizes :reason, with: ->(reason) { reason.to_s.unicode_normalize(:nfc).normalize_whitespace.strip }

  before_validation { user&.lock! }
  validates :duration, presence: true
  validates :duration, inclusion: { in: DURATIONS, message: "%{value} is not a valid ban duration" }, if: :duration_changed?
  validates :reason, visible_string: true, length: { maximum: 600 }, if: :reason_changed?
  validate :validate_ban_is_editable, on: :update
  validate :validate_user_is_bannable, on: :create
  validate :validate_deletions, on: :create

  scope :unexpired, -> { where("bans.created_at + bans.duration > ?", Time.zone.now) }
  scope :expired, -> { where("bans.created_at + bans.duration <= ?", Time.zone.now) }
  scope :active, -> { unexpired }

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :duration, :reason, :user, :banner], current_user: current_user)

    q = q.expired if params[:expired].to_s.truthy?
    q = q.unexpired if params[:expired].to_s.falsy?

    case params[:order]
    when "expires_at_desc"
      q = q.order(Arel.sql("bans.created_at + bans.duration DESC"))
    else
      q = q.apply_default_order(params)
    end

    q
  end

  def self.prune!
    users = User.banned.where.not(id: Ban.active.select(:user_id))
    users.find_each(&:unban!)
  end

  def validate_ban_is_editable
    if created_at + duration_was < Time.zone.now
      errors.add(:base, "You can't update an expired ban")
    end
  end

  def validate_user_is_bannable
    errors.add(:user, "is already banned") if user&.is_banned? || user&.bans&.active&.exists?
  end

  def validate_deletions
    if delete_posts && !post_deletion_reason.present?
      errors.add(:post_deletion_reason, "is required")
    end

    if delete_post_votes && !Pundit.policy!(banner, PostVote.new).destroy?
      errors.add(:delete_post_votes, "is not allowed by #{banner.level_string}")
    end

    if delete_comment_votes && !Pundit.policy!(banner, CommentVote.new).destroy?
      errors.add(:delete_comment_votes, "is not allowed by #{banner.level_string}")
    end
  end

  def update_user_on_save
    user.update!(is_banned: user.bans.active.exists?)
  end

  def user_name
    user ? user.name : nil
  end

  def user_name=(username)
    self.user = User.find_by_name(username)
  end

  def expires_at
    created_at + duration
  end

  def humanized_duration
    if forever?
      "forever"
    elsif duration < 0
      # In production, the oldest bans have negative duration because in 2013 the database was migrated and the
      # created_at field was reset to 2013, which made their creation date come after their expiration date.
      "unknown"
    elsif duration < 1.month
      duration.in_days.round.days.inspect
    elsif duration < 1.year
      duration.in_months.round.months.inspect
    elsif duration < 100.years
      duration.in_years.round.years.inspect
    else
      duration.inspect
    end
  end

  def forever?
    duration.present? && duration >= 100.years
  end

  def expired?
    persisted? && expires_at < Time.zone.now
  end

  def create_feedback
    user.feedback.create!(creator: banner, category: "negative", body: "Banned #{humanized_duration}: #{reason}", disable_dmail_notification: true)
  end

  def create_dmail
    Dmail.create_automated(to: user, title: "You have been banned", body: "You have been banned #{forever? ? "forever" : "for #{humanized_duration}"}: #{reason}")
  end

  def create_mod_action
    if previously_new_record?
      ModAction.log(%{banned <@#{user_name}> #{humanized_duration}: #{reason}}, :user_ban, subject: user, user: banner)
    elsif saved_changes? && updater.present?
      ModAction.log(%{updated ban #{saved_changes.keys.without("updated_at").to_sentence} for <@#{user_name}>}, :user_ban_update, subject: user, user: updater)
    end
  end

  def create_unban_mod_action
    ModAction.log(%{unbanned <@#{user_name}>}, :user_unban, subject: user, user: updater) if updater.present?
  end

  def delete_user_data(since: MAX_DELETION_AGE.ago)
    if delete_posts
      user.posts.pending.where(created_at: since..).find_each do |post|
        post.delete!(post_deletion_reason, user: banner)
      end
    end

    if delete_forum_posts
      user.forum_topics.undeleted.where(created_at: since..).find_each do |topic|
        topic.soft_delete!(updater: banner)
      end

      user.forum_posts.undeleted.where(created_at: since..).find_each do |post|
        post.soft_delete!(updater: banner)
      end
    end

    if delete_comments
      user.comments.undeleted.where(created_at: since..).find_each do |comment|
        comment.soft_delete!(updater: banner)
      end
    end

    if delete_post_votes
      user.post_votes.undeleted.where(created_at: since..).find_each do |vote|
        vote.soft_delete!(updater: banner)
      end
    end

    if delete_comment_votes
      user.comment_votes.undeleted.where(created_at: since..).find_each do |vote|
        vote.soft_delete!(updater: banner)
      end
    end
  end

  def self.available_includes
    [:user, :banner]
  end
end
