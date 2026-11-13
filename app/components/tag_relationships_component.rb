# frozen_string_literal: true

# The list of aliases, implications, and automatic tags shown under a tag's wiki or artist entry.
class TagRelationshipsComponent < ApplicationComponent
  extend Memoist

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

  def tag_links(tags)
    to_sentence(tags.map { |t| link_to_wiki_or_artist(t) })
  end
end
