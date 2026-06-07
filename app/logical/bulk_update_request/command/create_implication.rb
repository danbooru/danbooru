# frozen_string_literal: true

# Makes adding the subtag to a post automatically add the main tag as well.
class BulkUpdateRequest::Command::CreateImplication < BulkUpdateRequest::Command
  def self.regex
    /\A(?:create implication|imply) (?<antecedent>\S+) -> (?<consequent>\S+)\z/i
  end

  def initialize(params)
    super
    @antecedent = Tag.normalize_name(params[:antecedent])
    @consequent = Tag.normalize_name(params[:consequent])
  end

  def affected_tags
    [@antecedent, @consequent]
  end

  def process!(approver:, forum_topic:)
    TagImplication.approve!(antecedent_name: @antecedent, consequent_name: @consequent, approver: approver, forum_topic: forum_topic)
  end

  def to_dtext
    "create implication [[#{@antecedent}]] -> [[#{@consequent}]]"
  end

  def validate(context:, errors:)
    tag_implication = TagImplication.new(creator: User.system, antecedent_name: @antecedent, consequent_name: @consequent, status: "active")
    tag_implication.save(context: context)
    if tag_implication.errors.present?
      errors.add(:base, "Can't create implication [[#{tag_implication.antecedent_name}]] -> [[#{tag_implication.consequent_name}]] (#{tag_implication.errors.full_messages.join("; ")})")
    end
  end
end
