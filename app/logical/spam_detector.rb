# https://github.com/joshfrench/rakismet
# https://akismet.com/development/api/#comment-check

class SpamDetector
  include Rakismet::Model

  attr_accessor :user, :user_ip, :content, :comment_type
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
  rescue
    false
  end

  def initialize(record)
    case record
    when Dmail
      @user = record.from
      @content = record.body
      @comment_type = "message"
      @user_ip = record.creator_ip_addr.to_s
    else
      raise ArgumentError
    end
  end

  def spam?
    return false if !SpamDetector.enabled?
    return false if user.is_gold?
    super
  end
end
