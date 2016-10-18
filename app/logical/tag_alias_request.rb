class TagAliasRequest
  include ActiveModel::Validations

  attr_reader :antecedent_name, :consequent_name, :reason, :skip_secondary_validations, :tag_alias, :forum_topic

  validate :validate_tag_alias
  validate :validate_forum_topic

  def initialize(attributes)
    @antecedent_name = attributes[:antecedent_name].strip.tr(" ", "_")
    @consequent_name = attributes[:consequent_name].strip.tr(" ", "_")
    @reason = attributes[:reason]
    self.skip_secondary_validations = attributes[:skip_secondary_validations]
  end

  def create
    return false if invalid?

    TagAlias.transaction do
      @tag_alias = build_tag_alias
      @tag_alias.save

      @forum_topic = build_forum_topic(@tag_alias.id)
      @forum_topic.save

      @tag_alias.update_attribute(:forum_topic_id, @forum_topic.id)
    end
  end

  def build_tag_alias
    x = TagAlias.new(
      :antecedent_name => antecedent_name, 
      :consequent_name => consequent_name, 
      :skip_secondary_validations => skip_secondary_validations
    )
    x.status = "pending"
    x
  end

  def build_forum_topic(tag_alias_id)
    ForumTopic.new(
      :title => "Tag alias: #{antecedent_name} -> #{consequent_name}",
      :original_post_attributes => {
        :body => "create alias [[#{antecedent_name}]] -> [[#{consequent_name}]]\n\n\"Link to alias\":/tag_aliases?search[id]=#{tag_alias_id}\n\n#{reason}"
      },
      :category_id => 1
    )
  end

  def validate_tag_alias
    ta = @tag_alias || build_tag_alias

    if ta.invalid?
      self.errors.add(:base, ta.errors.full_messages.join("; ")) 
      return false
    end
  end

  def validate_forum_topic
    ft = @forum_topic || build_forum_topic(nil)
    if ft.invalid?
      self.errors.add(:base, ft.errors.full_messages.join("; ")) 
      return false
    end
  end

  def skip_secondary_validations=(v)
    if v == "1" or v == true
      @skip_secondary_validations = true
    else
      @skip_secondary_validations = false
    end
  end
end
