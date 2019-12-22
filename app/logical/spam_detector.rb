# https://github.com/joshfrench/rakismet
# https://akismet.com/development/api/#comment-check

class SpamDetector
  include Rakismet::Model

  attr_accessor :record, :user, :user_ip, :content, :comment_type
  rakismet_attrs author: proc { user.name },
                 author_email: proc { user.email },
                 blog_lang: "en",
                 blog_charset: "UTF-8",
                 comment_type: :comment_type,
                 content: :content,
                 user_ip: :user_ip

  def self.enabled?
    Danbooru.config.rakismet_key.present? && Danbooru.config.rakismet_url.present? && !Rails.env.test?
  end

  # rakismet raises an exception if the api key or url aren't configured
  def self.working?
    Rakismet.validate_key
  rescue StandardError
    false
  end

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

  def spam?
    return false if !SpamDetector.enabled?
    return false if user.is_gold?
    return false if user.created_at < 1.month.ago

    is_spam = super

    if is_spam
      DanbooruLogger.info("Spam detected: user_name=#{user.name} comment_type=#{comment_type} content=#{content.dump}", record.as_json)
    end

    is_spam
  rescue StandardError => exception
    DanbooruLogger.log(exception)
    false
  end
end
