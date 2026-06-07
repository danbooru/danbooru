# frozen_string_literal: true

# Marks a tag as deprecated, preventing it from being added to new posts while leaving existing posts intact.
# Active aliases pointing to the tag and active implications involving the tag are removed.
# The tag must have a valid wiki page.
class BulkUpdateRequest::Command::Deprecate < BulkUpdateRequest::Command
  def self.regex
    /\Adeprecate (?<tag_name>\S+)\z/i
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
    tag.update!(is_deprecated: true, updater: User.system)
    TagAlias.active.where(consequent_name: tag.name).find_each(&:reject!)
    TagImplication.active.where(consequent_name: tag.name).find_each(&:reject!)
    TagImplication.active.where(antecedent_name: tag.name).find_each(&:reject!)
  end

  def to_dtext
    "deprecate [[#{@tag_name}]]"
  end

  def affected_tag
    @affected_tag ||= Tag.find_by_name(@tag_name)
  end

  def validate(context:, errors:)
    if context == :approval
      # ignore already deprecated tags and missing wikis when approving a tag deprecation
    elsif affected_tag.nil?
      errors.add(:base, "Can't deprecate [[#{@tag_name}]] (tag doesn't exist)")
    elsif affected_tag.is_deprecated?
      errors.add(:base, "Can't deprecate [[#{@tag_name}]] (tag is already deprecated)")
    elsif affected_tag.wiki_page.blank?
      errors.add(:base, "Can't deprecate [[#{@tag_name}]] (tag must have a wiki page)")
    elsif affected_tag.wiki_page.is_deleted?
      errors.add(:base, "Can't deprecate [[#{@tag_name}]] (wiki page is deleted)")
    end
  end
end
