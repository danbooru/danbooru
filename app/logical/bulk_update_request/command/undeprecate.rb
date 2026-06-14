# frozen_string_literal: true

# Reverses a previous deprecation, allowing the tag to be added to posts again.
class BulkUpdateRequest::Command::Undeprecate < BulkUpdateRequest::Command
  def self.regex
    /\Aundeprecate (?<tag_name>\S+)\z/i
  end

  def initialize(params)
    super
    @tag_name = Tag.normalize_name(params[:tag_name])
  end

  def affected_tags
    [affected_tag&.name].compact
  end

  def process!(**)
    tag = Tag.find_or_create_by_name(@tag_name)
    tag.update!(is_deprecated: false, updater: User.system)
  end

  def to_dtext
    "undeprecate [[#{@tag_name}]]"
  end

  def affected_tag
    @affected_tag ||= Tag.find_by_name(@tag_name)
  end

  def validate(context:, errors:)
    if context == :approval
      # ignore already undeprecated tags when removing a tag deprecation
    elsif affected_tag.nil?
      errors.add(:base, "Can't undeprecate [[#{@tag_name}]] (tag doesn't exist)")
    elsif !affected_tag.is_deprecated?
      errors.add(:base, "Can't undeprecate [[#{@tag_name}]] (tag is not deprecated)")
    end
  end
end
