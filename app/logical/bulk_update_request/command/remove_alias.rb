# frozen_string_literal: true

# Removes an existing tag alias, stopping the automatic redirect from the old tag to the new tag.
class BulkUpdateRequest::Command::RemoveAlias < BulkUpdateRequest::Command
  def self.regex
    /\A(?:remove alias|unalias) (?<antecedent>\S+) -> (?<consequent>\S+)\z/i
  end

  def initialize(params)
    super
    @antecedent = Tag.normalize_name(params[:antecedent])
    @consequent = Tag.normalize_name(params[:consequent])
  end

  def affected_tags
    [@antecedent, @consequent]
  end

  def existing_alias
    TagAlias.active.find_by(antecedent_name: @antecedent, consequent_name: @consequent)
  end

  def process!(**)
    existing_alias&.reject!
  end

  def to_dtext
    "remove alias [[#{@antecedent}]] -> [[#{@consequent}]]"
  end

  def validate(context:, errors:)
    if context == :approval
      # ignore non-existing aliases when approving a BUR
    elsif existing_alias.nil?
      errors.add(:base, "Can't remove alias [[#{@antecedent}]] -> [[#{@consequent}]] (alias doesn't exist)")
    else
      existing_alias.update(status: "deleted")
    end
  end
end
