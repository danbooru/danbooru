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
    title = self.class.mentionable_option(:title)
    from_id = read_attribute(self.class.mentionable_option(:user_field))
    text = read_attribute(self.class.mentionable_option(:message_field))

    text.scan(DText::MENTION_REGEXP).each do |mention|
      mention.gsub!(/(?:^\s*@)|(?:[:;,.!?\)\]<>]$)/, "")
      user = User.find_by_name(mention)
      body = self.class.mentionable_option(:body).call(self, user.name)

      if user
        dmail = Dmail.new(
          from_id: from_id,
          to_id: user.id,
          title: title,
          body: body
        )
        dmail.owner_id = user.id
        dmail.save
      end
    end
  end
end
