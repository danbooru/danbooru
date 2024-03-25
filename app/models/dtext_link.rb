# frozen_string_literal: true

class DtextLink < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :linked_wiki, primary_key: :title, foreign_key: :link_target, class_name: "WikiPage", optional: true
  belongs_to :linked_tag, primary_key: :name, foreign_key: :link_target, class_name: "Tag", optional: true
  belongs_to :embedded_post, foreign_key: :link_target, class_name: "Post", optional: true
  belongs_to :embedded_media_asset, foreign_key: :link_target, class_name: "MediaAsset", optional: true

  enum link_type: {
    wiki_link: 0,
    external_link: 1,
    embedded_post: 2,
    embedded_media_asset: 3,
  }

  before_validation :normalize_link_target
  # validates :link_target, uniqueness: { scope: [:model_type, :model_id] }

  scope :wiki_page, -> { where(model_type: "WikiPage") }
  scope :forum_post, -> { where(model_type: "ForumPost") }
  scope :pool, -> { where(model_type: "Pool") }

  def self.visible(user)
    # XXX the double negation is to prevent postgres from choosing a bad query
    # plan (it doesn't know that most forum posts aren't mod-only posts).
    wiki_page.or(forum_post.where.not(model_id: ForumPost.not_visible(user))).or(pool)
  end

  def self.model_types
    %w[WikiPage ForumPost Pool]
  end

  # @param dtext [DText]
  def self.new_from_dtext(dtext)
    links = []

    links += dtext.wiki_titles.map do |link|
      DtextLink.new(link_type: :wiki_link, link_target: link)
    end

    links += dtext.external_links.map do |link|
      DtextLink.new(link_type: :external_link, link_target: link)
    end

    links += dtext.embedded_post_ids.map do |post_id|
      DtextLink.new(link_type: :embedded_post, link_target: post_id)
    end

    links += dtext.embedded_media_asset_ids.map do |media_asset_id|
      DtextLink.new(link_type: :embedded_media_asset, link_target: media_asset_id)
    end

    links
  end

  def self.search(params, current_user)
    q = search_attributes(params, [:id, :created_at, :updated_at, :link_type, :link_target, :model, :linked_wiki, :linked_tag], current_user: current_user)
    q.apply_default_order(params)
  end

  def normalize_link_target
    if wiki_link?
      self.link_target = WikiPage.normalize_title(link_target)
    end

    # postgres will raise an error if the link is more than 2712 bytes long
    # because it can't index values that take up more than 1/3 of an 8kb page.
    self.link_target = link_target.truncate(2048, omission: "")
  end

  def self.attribute_restriction(*)
    where(link_type: :wiki_link)
  end

  def self.available_includes
    [:model, :linked_wiki, :linked_tag, :embedded_post, :embedded_media_asset]
  end
end
