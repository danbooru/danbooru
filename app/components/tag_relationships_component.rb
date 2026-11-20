# frozen_string_literal: true

# The list of aliases, implications, and automatic tags shown under a tag's wiki or artist entry.
class TagRelationshipsComponent < ApplicationComponent
  extend Memoist

  # Lists longer than this are truncated, with a link to the full list.
  MAX_VISIBLE_TAGS = 10

  attr_reader :tag

  delegate :link_to_wiki, :link_to_wiki_or_artist, to: :helpers

  def initialize(tag:)
    super
    @tag = tag
  end

  def render?
    tag.present?
  end

  memoize def aliased_tag
    tag.antecedent_alias&.consequent_tag
  end

  memoize def alias_tags
    tag.consequent_aliases.includes(:antecedent_tag).sort_by(&:antecedent_name).map(&:antecedent_tag)
  end

  # Tags that don't exist yet are shown as general tags.
  memoize def automatic_tags
    names = Tag.automatic_tags_for([tag.name])
    tags = Tag.where(name: names).index_by(&:name)
    names.map { |name| tags[name] || Tag.new(name: name) }
  end

  memoize def implied_tags
    tag.antecedent_implications.includes(:consequent_tag).sort_by(&:consequent_name).map(&:consequent_tag)
  end

  memoize def implying_tags
    tag.consequent_implications.includes(:antecedent_tag).sort_by(&:antecedent_name).map(&:antecedent_tag)
  end

  def alias_tags_url
    tag_aliases_path(search: { consequent_name: tag.name, status: "active", order: "name" })
  end

  def implied_tags_url
    tag_implications_path(search: { antecedent_name: tag.name, status: "active", order: "name" })
  end

  def implying_tags_url
    tag_implications_path(search: { consequent_name: tag.name, status: "active", order: "name" })
  end

  # @param tags [Array<Tag>] the tags to list
  # @param more_url [String, nil] the link to the full list, if the list is truncated
  def tag_links(tags, more_url: nil)
    return to_sentence(tags.map { |t| link_to_wiki_or_artist(t) }) if more_url.blank? || tags.size <= MAX_VISIBLE_TAGS

    # Show one less tag to make room for the "N more" link.
    visible_tags = tags.first(MAX_VISIBLE_TAGS - 1)
    links = visible_tags.map { |t| link_to_wiki_or_artist(t) }
    to_sentence(links + [link_to("#{tags.size - visible_tags.size} more", more_url)])
  end
end
