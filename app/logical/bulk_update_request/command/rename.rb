# frozen_string_literal: true

# Just like an alias, but without permanent redirect.
#
# @see TagMover
class BulkUpdateRequest::Command::Rename < BulkUpdateRequest::Command::CreateAlias
  # Rename can only be used for tags containing up to this amount of posts
  MAXIMUM_RENAME_COUNT = 200

  def self.regex
    /\Arename (?<old_name>\S+) -> (?<new_name>\S+)\z/i
  end

  def process!(**)
    TagMover.new(@old_name, @new_name).move!
  end

  def to_dtext
    "rename [[#{@old_name}]] -> [[#{@new_name}]]"
  end

  def validate(errors:, **)
    new_tag ||= Tag.new(name: @new_name)

    if old_tag.nil?
      errors.add(:base, "Can't rename [[#{@old_name}]] -> [[#{@new_name}]] ([[#{@old_name}]] doesn't exist)")
    elsif old_tag.post_count > MAXIMUM_RENAME_COUNT
      errors.add(:base, "Can't rename [[#{@old_name}]] -> [[#{@new_name}]] ([[#{@old_name}]] has more than #{MAXIMUM_RENAME_COUNT} posts, use an alias instead)")
    elsif new_tag.invalid?(:name)
      errors.add(:base, "Can't rename [[#{@old_name}]] -> [[#{@new_name}]] (#{new_tag.errors.full_messages.join("; ")})")
    end
  end
end
