class TagImplicationRequest
  class ValidationError < Exception ; end

  attr_reader :antecedent_name, :consequent_name, :reason, :tag_implication, :forum_topic

  def initialize(antecedent_name, consequent_name, reason)
    @antecedent_name = antecedent_name.strip.tr(" ", "_")
    @consequent_name = consequent_name.strip.tr(" ", "_")
    @reason = reason
  end

  def create
    TagImplication.transaction do
      create_implication
      create_forum_topic
    end
  end

  def create_implication
    @tag_implication = TagImplication.create(:antecedent_name => antecedent_name, :consequent_name => consequent_name, :status => "pending")
    if @tag_implication.errors.any?
      raise ValidationError.new(@tag_implication.errors.full_messages.join("; "))
    end
  end

  def create_forum_topic
    @forum_topic = ForumTopic.create(
      :title => "Tag implication: #{antecedent_name} -> #{consequent_name}",
      :original_post_attributes => {
        :body => "create implication [[#{antecedent_name}]] -> [[#{consequent_name}]]\n\n\"Link to implication\":/tag_implications?search[id]=#{tag_implication.id}\n\n#{reason}"
      },
      :category => 1
    )
    if @forum_topic.errors.any?
      raise ValidationError.new(@forum_topic.errors.full_messages.join("; "))
    end

    tag_implication.update_attribute(:forum_topic_id, @forum_topic.id)
  end
end
