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

  def strip_quote_blocks(str)
    stripped = ""
    str.gsub!(/\s*\[quote\](?!\])\s*/m, "\n\n[quote]\n\n")
    str.gsub!(/\s*\[\/quote\]\s*/m, "\n\n[/quote]\n\n")
    str.gsub!(/(?:\r?\n){3,}/, "\n\n")
    str.strip!
    nest = 0
    str.split(/\n{2}/).each do |block|
      if block == "[quote]"
        nest += 1

      elsif block == "[/quote]"
        nest -= 1

      elsif nest == 0
        stripped << "#{block}\n"
      end
    end

    stripped
  end

  def queue_mention_messages
    title = self.class.mentionable_option(:title)
    from_id = read_attribute(self.class.mentionable_option(:user_field))
    text = strip_quote_blocks(read_attribute(self.class.mentionable_option(:message_field)))
    bodies = {}

    text.scan(DText::MENTION_REGEXP).each do |mention|
      mention.gsub!(/(?:^\s*@)|(?:[:;,.!?\)\]<>]$)/, "")
      bodies[mention] = self.class.mentionable_option(:body).call(self, mention)
    end

    bodies.each do |name, text|
      user = User.find_by_name(name)

      if user
        dmail = Dmail.new(
          from_id: from_id,
          to_id: user.id,
          title: title,
          body: text
        )
        dmail.owner_id = user.id
        dmail.save
      end
    end
  end
end
