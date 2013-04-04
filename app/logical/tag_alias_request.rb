class TagAliasRequest
  class ValidationError < Exception ; end

  attr_reader :antecedent_name, :consequent_name, :reason, :tag_alias, :forum_topic

  def initialize(antecedent_name, consequent_name, reason)
    @antecedent_name = antecedent_name.strip.tr(" ", "_")
    @consequent_name = consequent_name.strip.tr(" ", "_")
    @reason = reason
  end

  def create
    TagAlias.transaction do
      create_alias
      create_forum_topic
    end
  end

  def create_alias
    @tag_alias = TagAlias.create(:antecedent_name => antecedent_name, :consequent_name => consequent_name, :status => "pending")
    if @tag_alias.errors.any?
      raise ValidationError.new(@tag_alias.errors.full_messages.join("; "))
    end
  end

  def create_forum_topic
    @forum_topic = ForumTopic.create(
      :title => "Tag alias: #{antecedent_name} -> #{consequent_name}",
      :original_post_attributes => {
        :body => "create alias [[#{antecedent_name}]] -> [[#{consequent_name}]]\n\n\"Link to alias\":/tag_aliases?search[id]=#{tag_alias.id}\n\n#{reason}"
      }
    )
    if @forum_topic.errors.any?
      raise ValidationError.new(@forum_topic.errors.full_messages.join("; "))
    end

    tag_alias.update_attribute(:forum_topic_id, @forum_topic.id)
  end
end
