# frozen_string_literal: true

# Removes an existing tag implication, so the subtag no longer automatically adds the main tag.
class BulkUpdateRequest::Command::RemoveImplication < BulkUpdateRequest::Command
  def self.regex
    /\A(?:remove implication|unimply) (?<antecedent>\S+) -> (?<consequent>\S+)\z/i
  end

  def initialize(params)
    super
    @antecedent = Tag.normalize_name(params[:antecedent])
    @consequent = Tag.normalize_name(params[:consequent])
  end

  def affected_tags
    [@antecedent, @consequent]
  end

  def existing_implication
    TagImplication.active.find_by(antecedent_name: @antecedent, consequent_name: @consequent)
  end

  def process!(**)
    existing_implication&.reject!
  end

  def to_dtext
    "remove implication [[#{@antecedent}]] -> [[#{@consequent}]]"
  end

  def validate(context:, errors:)
    if existing_implication.nil?
      errors.add(:base, "Can't remove implication [[#{@antecedent}]] -> [[#{@consequent}]] (implication doesn't exist)") unless context == :approval
    else
      existing_implication.update(status: "deleted")
    end
  end
end
