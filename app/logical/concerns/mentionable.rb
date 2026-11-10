# frozen_string_literal: true

# A concern that handles @mentions in comments and forum posts. Sends a DMail
# to mentioned users when a comment or forum post is created or edited to add
# new mentions.
module Mentionable
  extend Memoist
  extend ActiveSupport::Concern

  # The maximum number of users that can be mentioned in a single message.
  MAX_MENTIONS = 10

  # Each newly mentioned user costs one point. Points refill at this rate, up to the burst limit.
  MENTION_BURST = 20
  MENTION_RATE = 1.0 / 1.minute

  included do
    attr_accessor :skip_mention_notifications
  end

  module ClassMethods
    # options:
    # - message_field
    # - user_field
    def mentionable(options = {})
      @mentionable_options = options
      validate :validate_mention_count, :validate_mention_author, :validate_mention_rate_limit, if: :check_mentions?
      after_save :queue_mention_messages
    end

    def mentionable_option(key)
      @mentionable_options[key]
    end
  end

  def validate_mention_count
    if DText.new(send(mention_field)).mentions.size > MAX_MENTIONS
      errors.add(mention_field, "can't mention more than #{MAX_MENTIONS} users")
    end
  end

  # The mention dmails say the author mentioned the user, so other people can't add mentions.
  def validate_mention_author
    return if errors.any? || CurrentUser.user.nil? || CurrentUser.id == creator_id

    if new_mentioned_users(send(mention_field), attribute_in_database(mention_field)).present?
      errors.add(:base, "You can't mention users in someone else's message")
    end
  end

  def validate_mention_rate_limit
    return if errors.any?

    if mention_rate_limited?(send(mention_field), attribute_in_database(mention_field))
      errors.add(:base, "You've mentioned too many users recently. Wait a while and try again")
    end
  end

  # Memoized because policies call `invalid?` before the record is saved, which would charge the rate limit twice.
  memoize def mention_rate_limited?(text, text_was)
    cost = new_mentioned_users(text, text_was).size
    cost > 0 && RateLimiter.limited?(action: "mentions", user: creator, cost:, rate: MENTION_RATE, burst: MENTION_BURST, minimum_points: -0.1)
  end

  def queue_mention_messages
    return if !saved_change_to_attribute?(mention_field) || skip_mention_notifications

    new_mentioned_users(send(mention_field), attribute_before_last_save(mention_field)).each do |user|
      body  = instance_exec(user.name, &self.class.mentionable_option(:body))
      title = instance_exec(user.name, &self.class.mentionable_option(:title))

      Dmail.create_automated(to: user, title: title, body: body)
    end
  end

  # Memoized so that validating and sending the dmails only looks up the users once.
  #
  # @return [Array<User>] The users mentioned in `text` but not in `text_was`, excluding the author.
  memoize def new_mentioned_users(text, text_was)
    names = DText.new(text).mentions - DText.new(text_was).mentions
    return [] if names.empty?

    User.where_text_includes_lower(:name, names).where.not(id: creator_id).to_a
  end

  def check_mentions?
    will_save_change_to_attribute?(mention_field) && !skip_mention_notifications
  end

  def mention_field
    self.class.mentionable_option(:message_field)
  end
end
