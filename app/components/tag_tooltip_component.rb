# frozen_string_literal: true

# The tooltip that displays when you hover over a tag.
class TagTooltipComponent < ApplicationComponent
  attr_reader :tag, :current_user

  delegate :humanized_number, :link_to_wiki_or_artist, to: :helpers
  delegate :wiki_page, :aliased_tag, :is_aliased?, to: :tag

  def initialize(tag:, current_user: CurrentUser.user)
    super
    @tag = tag
    @current_user = current_user
  end

  # @return [WikiPage, nil] The wiki page, or nil if it's deleted or hidden and shouldn't be excerpted.
  def visible_wiki_page
    return nil if wiki_page.blank? || wiki_page.is_deleted? || tag.artist&.is_banned?
    wiki_page
  end

  # @return [Hash, nil] see {DText#tooltip_excerpt}
  def excerpt
    @excerpt ||= visible_wiki_page&.dtext_body&.tooltip_excerpt(current_user: current_user)
  end

  def paragraph
    excerpt&.dig(:paragraph)
  end

  # @return [Boolean] true if the tag is an artist tag without a meaningful wiki page.
  def artist_without_wiki?
    tag.artist? && paragraph.blank?
  end

  # @return [Nokogiri::HTML5::Node, nil] The wiki page's first media embed, if any.
  # Not shown for artist wikis or if the wiki page has no meaningful text.
  def embed
    return nil if tag.artist? || paragraph.blank?
    excerpt&.dig(:embed)
  end

  # @return [String, nil] The rendered media embed's HTML.
  def embed_html
    embed&.to_html&.html_safe
  end

  # Only place the embed above the text (instead of beside it) if it's substantially wider than tall
  def horizontal_embed?
    image = embed&.at_css("img")
    image.present? && image["width"].to_i > image["height"].to_i * 2
  end

  # @return [Boolean] true if the small edit button should be displayed
  def display_edit_button?
    return false if is_aliased?
    return false if artist_without_wiki? # we don't want to encourage these
    wiki_page.present? ? policy(wiki_page).edit? : policy(WikiPage).new?
  end

  # @return [String] The path to edit the wiki page, or to create it if it doesn't exist yet.
  def wiki_page_edit_path
    wiki_page.present? ? edit_wiki_page_path(wiki_page) : new_wiki_page_path(wiki_page: { title: tag.name })
  end
end
