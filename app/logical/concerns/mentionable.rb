# frozen_string_literal: true

# A concern that handles @mentions in comments and forum posts. Sends a DMail
# to mentioned users when a comment or forum post is created or edited to add
# new mentions.
module Mentionable
  extend ActiveSupport::Concern

  # The maximum number of users that can be mentioned in a single message.
  MAX_MENTIONS = 10

  included do
    attr_accessor :skip_mention_notifications
  end

  module ClassMethods
    # options:
    # - message_field
    # - user_field
    def mentionable(options = {})
      @mentionable_options = options
      validate :validate_mention_count, :validate_mention_author, if: :check_mentions?
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

  def queue_mention_messages
    return if !saved_change_to_attribute?(mention_field) || skip_mention_notifications

    new_mentioned_users(send(mention_field), attribute_before_last_save(mention_field)).each do |user|
      body  = instance_exec(user.name, &self.class.mentionable_option(:body))
      title = instance_exec(user.name, &self.class.mentionable_option(:title))

      Dmail.create_automated(to: user, title: title, body: body)
    end
  end

  # @return [Array<User>] The users mentioned in `text` but not in `text_was`, excluding the author.
  def new_mentioned_users(text, text_was)
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
