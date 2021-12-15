# frozen_string_literal: true

# Detects whether a dmail, comment, or forum post seems like spam. Autobans
# users who receive more than 10 spam reports in an hour. Uses the Akismet spam
# detection service.
#
# @see https://github.com/joshfrench/rakismet
# @see https://akismet.com/development/api/#comment-check
class SpamDetector
  include Rakismet::Model

  # If a person receives more than 10 automatic spam reports within a 1 hour
  # window, automatically ban them forever.
  AUTOBAN_THRESHOLD = 10
  AUTOBAN_WINDOW = 1.hour
  AUTOBAN_DURATION = 100.years

  attr_accessor :record, :user, :user_ip, :content, :comment_type

  # The attributes to pass to Akismet
  rakismet_attrs author: proc { user.name },
                 author_email: proc { user.email_address&.address },
                 blog_lang: "en",
                 blog_charset: "UTF-8",
                 comment_type: :comment_type,
                 content: :content,
                 user_ip: :user_ip

  # @return [Boolean] true if the Akismet API keys are configured
  def self.enabled?
    Danbooru.config.rakismet_key.present? && Danbooru.config.rakismet_url.present? && !Rails.env.test?
  end

  # @return [Boolean] true if the Akismet API keys are valid. Rakismet raises
  #   an exception if the API key or URL aren't configured
  def self.working?
    Rakismet.validate_key
  rescue StandardError
    false
  end

  # Check if the user seems like a spammer and should be banned. Checks if they
  # have received more than 10 automatic spam reports in the last hour.
  # @param user [User] the user to check
  # @return [Boolean] true if the user should be autobanned
  def self.is_spammer?(user)
    return false if user.is_gold?

    automatic_reports = ModerationReport.where("created_at > ?", AUTOBAN_WINDOW.ago).where(creator: User.system)

    dmail_reports = automatic_reports.where(model: Dmail.sent_by(user))
    comment_reports = automatic_reports.where(model: user.comments)
    forum_post_reports = automatic_reports.where(model: user.forum_posts)

    report_count = dmail_reports.or(comment_reports).or(forum_post_reports).count
    report_count >= AUTOBAN_THRESHOLD
  end

  # Autobans a user.
  # @param spammer [User] the user to ban
  def self.ban_spammer!(spammer)
    spammer.bans.create!(banner: User.system, reason: "Spambot.", duration: AUTOBAN_DURATION)
  end

  # Initialize a spam check for a message.
  # @param record [Dmail, ForumPost, Comment] the message to spam check
  # @param user_ip [String] the IP address of the user who posted the message
  def initialize(record, user_ip: nil)
    case record
    when Dmail
      @record = record
      @user = record.from
      @content = record.body
      @comment_type = "message"
      @user_ip = user_ip || record.creator_ip_addr.to_s
    when ForumPost
      @record = record
      @user = record.creator
      @content = record.body
      @comment_type = record.is_original_post? ? "forum-post" : "reply"
      @user_ip = user_ip
    when Comment
      @record = record
      @user = record.creator
      @content = record.body
      @comment_type = "comment"
      @user_ip = user_ip || record.creator_ip_addr.to_s
    else
      raise ArgumentError
    end
  end

  # Check if a message seems like spam. Gold users and users who have an account
  # more than a month old aren't checked to reduce the number of API calls.
  # @return [Boolean] true if the message is spam
  def spam?
    return false if !SpamDetector.enabled?
    return false if user.is_gold?
    return false if user.created_at < 1.month.ago

    is_spam = super

    if is_spam
      DanbooruLogger.info("Spam detected: user_name=#{user.name} comment_type=#{comment_type} content=#{content.dump}", record.as_json)
    end

    is_spam
  rescue StandardError => e
    DanbooruLogger.log(e)
    false
  end
end
