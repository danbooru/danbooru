# frozen_string_literal: true

# Merges tags and creates a permanent redirect from one tag to another.
#
# @see TagAlias
# @see TagMover
class BulkUpdateRequest::Command::CreateAlias < BulkUpdateRequest::Command
  # Aliases can be approved by non-admins for tags containing up to this amount of posts
  MAX_NON_ADMIN_APPROVABLE_POST_COUNT = 200

  def self.regex
    /\A(?:create alias|alias) (?<old_name>\S+) -> (?<new_name>\S+)\z/i
  end

  def initialize(params)
    super
    @old_name = Tag.normalize_name(params[:old_name])
    @new_name = Tag.normalize_name(params[:new_name])
  end

  def affected_tags
    [@old_name, @new_name]
  end

  def process!(approver:, forum_topic:)
    TagAlias.approve!(antecedent_name: @old_name, consequent_name: @new_name, approver: approver, forum_topic: forum_topic)
  end

  def to_dtext
    "create alias [[#{@old_name}]] -> [[#{@new_name}]]"
  end

  def validate(context:, errors:)
    tag_alias = TagAlias.new(creator: User.system, antecedent_name: @old_name, consequent_name: @new_name)
    tag_alias.save(context: context)
    if tag_alias.errors.present?
      errors.add(:base, "Can't create alias [[#{tag_alias.antecedent_name}]] -> [[#{tag_alias.consequent_name}]] (#{tag_alias.errors.full_messages.join("; ")})")
    end
  end

  def old_tag
    @old_tag ||= Tag.find_by_name(@old_name)
  end

  def new_tag
    @new_tag ||= Tag.find_by_name(@new_name)
  end

  def approval_level
    # the old tag is a small artist tag
    old_allowed = old_tag.present? && old_tag.artist? && old_tag.post_count < BulkUpdateRequest::Processor::MAX_NON_ADMIN_APPROVABLE_POST_COUNT
    # the new tag doesn't exist or is also a small artist tag
    new_allowed = new_tag.blank? || (new_tag.artist? && new_tag.post_count < BulkUpdateRequest::Processor::MAX_NON_ADMIN_APPROVABLE_POST_COUNT)

    return User::Levels::BUILDER if old_allowed && new_allowed
    User::Levels::ADMIN
  end
end
