module Mentionable
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_mention_notifications
  end

  module ClassMethods
    # options:
    # - message_field
    # - user_field
    def mentionable(options = {})
      @mentionable_options = options
      after_save :queue_mention_messages
    end

    def mentionable_option(key)
      @mentionable_options[key]
    end
  end

  def queue_mention_messages
    message_field = self.class.mentionable_option(:message_field)
    return if !send(:saved_change_to_attribute?, message_field)
    return if self.skip_mention_notifications

    text = send(message_field)
    text_was = send(:attribute_before_last_save, message_field)

    names = DText.parse_mentions(text) - DText.parse_mentions(text_was)

    names.uniq.each do |name|
      body  = self.instance_exec(name, &self.class.mentionable_option(:body))
      title = self.instance_exec(name, &self.class.mentionable_option(:title))

      Dmail.create_automated(to_name: name, title: title, body: body)
    end
  end
end
