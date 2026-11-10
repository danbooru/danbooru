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
      validate :validate_mention_count, if: :check_mentions?
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

  def queue_mention_messages
    message_field = self.class.mentionable_option(:message_field)
    return if !send(:saved_change_to_attribute?, message_field)
    return if self.skip_mention_notifications

    text = send(message_field)
    text_was = send(:attribute_before_last_save, message_field)

    names = DText.new(text).mentions - DText.new(text_was).mentions
    users = names.map { |name| User.find_by_name(name) }.compact.uniq
    users = users.without(CurrentUser.user)

    users.each do |user|
      body  = instance_exec(user.name, &self.class.mentionable_option(:body))
      title = instance_exec(user.name, &self.class.mentionable_option(:title))

      Dmail.create_automated(to: user, title: title, body: body)
    end
  end

  def check_mentions?
    will_save_change_to_attribute?(mention_field) && !skip_mention_notifications
  end

  def mention_field
    self.class.mentionable_option(:message_field)
  end
end
