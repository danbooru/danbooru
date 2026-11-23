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

  def process!(approver:, forum_topic:, **)
    TagAlias.approve!(antecedent_name: @old_name, consequent_name: @new_name, approver: approver, forum_topic: forum_topic)
  end

  def to_dtext
    "create alias [[#{@old_name}]] -> [[#{@new_name}]]"
  end

  def validate(context:, errors:, approver:)
    tag_alias = TagAlias.new(id: self.class.next_simulated_id, creator: User.system, antecedent_name: @old_name, consequent_name: @new_name)
    tag_alias.save(context: context)
    if tag_alias.errors.present?
      errors.add(:base, "Can't create alias [[#{tag_alias.antecedent_name}]] -> [[#{tag_alias.consequent_name}]] (#{tag_alias.errors.full_messages.join("; ")})")
    end

    # Aliasing also moves the old tag's implications and *_(cosplay) and *_(style) tags to the new tag, and copies the
    # old artist's ban to the new artist (see TagMover). Only admins can do this to big tags. Checked here instead of in
    # `approval_level` because it needs extra queries.
    return unless context == :approval && !approver.is_admin? && old_tag.present? && new_tag.present? && !new_tag.empty? && !new_tag.is_small_tag?

    # A general old tag becomes an artist tag when it's aliased to an artist tag (see TagMover#move_tag_category!).
    old_is_artist = old_tag.artist? || (old_tag.general? && new_tag.artist?)
    cosplay_tag = Tag.find_by_name("#{old_tag.name}_(cosplay)")
    style_tag = Tag.find_by_name("#{old_tag.name}_(style)") if old_is_artist

    if old_tag.antecedent_implications.exists?
      errors.add(:base, "Can't approve #{to_dtext} ([[#{old_tag.name}]] has implications; requires Admin)")
    elsif cosplay_tag.present? && !cosplay_tag.is_small_tag?
      errors.add(:base, "Can't approve #{to_dtext} ([[#{cosplay_tag.name}]] is too large; requires Admin)")
    elsif style_tag.present? && !style_tag.is_small_tag?
      errors.add(:base, "Can't approve #{to_dtext} ([[#{style_tag.name}]] is too large; requires Admin)")
    elsif old_is_artist && old_tag.artist&.is_banned?
      errors.add(:base, "Can't approve #{to_dtext} ([[#{old_tag.name}]] is a banned artist; requires Admin)")
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

    old_is_small_artist = old.present? && old.artist? && old.is_small_tag?
    new_is_small_artist = new.blank? || new.empty? || (new.artist? && new.is_small_tag?)
    return User::Levels::BUILDER if old_is_small_artist && new_is_small_artist

    old_is_small = old.blank? || old.empty? || old.is_small_tag?
    new_is_small = new.blank? || new.empty? || new.is_small_tag?
    return User::Levels::MODERATOR if old_is_small && new_is_small

    # Aliasing also changes the new tag's category if it's general and the old tag isn't. Only allow this for small new tags.
    changes_new_category = old.present? && new.present? && !old.general? && new.general?
    return User::Levels::MODERATOR if old_is_small && !changes_new_category

    User::Levels::ADMIN
  end
end
