# frozen_string_literal: true

# Merges tags and creates a permanent redirect from one tag to another.
#
# @see TagAlias
# @see TagMover
class BulkUpdateRequest::Command::CreateAlias < BulkUpdateRequest::Command
  def self.regex
    /\A(?:create alias|alias) (?<old_name>\S+) -> (?<new_name>\S+)\z/i
  end

  def initialize(params)
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

  def approval_level(tags: nil)
    old = tags.present? ? tags.find { |tag| tag.name == @old_name } : old_tag
    new = tags.present? ? tags.find { |tag| tag.name == @new_name } : new_tag

    old_is_small = old.present? && old.is_small_tag?
    old_is_small_artist = old_is_small && old.artist?

    new_is_small = new.blank? || new.empty? || new.is_small_tag?
    new_is_small_artist = new.blank? || new.empty? || (new.artist? && new.is_small_tag?)

    return User::Levels::BUILDER if old_is_small_artist && new_is_small_artist
    return User::Levels::MODERATOR if old_is_small && new_is_small
    User::Levels::ADMIN
  end
end
