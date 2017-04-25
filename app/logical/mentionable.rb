module Mentionable
  extend ActiveSupport::Concern

  module ClassMethods
    # options:
    # - message_field
    # - user_field
    def mentionable(options = {})
      @mentionable_options = options

      after_create :queue_mention_messages
    end

    def mentionable_option(key)
      @mentionable_options[key]
    end
  end

  def queue_mention_messages
    from_id = read_attribute(self.class.mentionable_option(:user_field))
    text = read_attribute(self.class.mentionable_option(:message_field))
    text = DText.strip_blocks(text, "quote")

    names = text.scan(DText::MENTION_REGEXP).map do |mention|
      mention.gsub!(/(?:^\s*@)|(?:[:;,.!?\)\]<>]$)/, "")
    end

    names.uniq.each do |name|
      body  = self.instance_exec(name, &self.class.mentionable_option(:body))
      title = self.instance_exec(name, &self.class.mentionable_option(:title))

      Dmail.create_automated(to_name: name, title: title, body: body)
    end
  end
end
