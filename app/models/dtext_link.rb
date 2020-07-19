class DtextLink < ApplicationRecord
  belongs_to :model, polymorphic: true
  belongs_to :linked_wiki, primary_key: :title, foreign_key: :link_target, class_name: "WikiPage", optional: true
  belongs_to :linked_tag, primary_key: :name, foreign_key: :link_target, class_name: "Tag", optional: true

  enum link_type: [:wiki_link, :external_link]

  before_validation :normalize_link_target
  # validates :link_target, uniqueness: { scope: [:model_type, :model_id] }

  scope :wiki_page, -> { where(model_type: "WikiPage") }
  scope :forum_post, -> { where(model_type: "ForumPost") }

  def self.model_types
    %w[WikiPage ForumPost]
  end

  def self.new_from_dtext(dtext)
    links = []

    links += DText.parse_wiki_titles(dtext).map do |link|
      DtextLink.new(link_type: :wiki_link, link_target: link)
    end

    links += DText.parse_external_links(dtext).map do |link|
      DtextLink.new(link_type: :external_link, link_target: link)
    end

    links
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :link_type, :link_target)
    q.apply_default_order(params)
  end

  def normalize_link_target
    if wiki_link?
      self.link_target = WikiPage.normalize_title(link_target)
    end

    # postgres will raise an error if the link is more than 2712 bytes long
    # because it can't index values that take up more than 1/3 of an 8kb page.
    self.link_target = self.link_target.truncate(2048, omission: "")
  end

  def self.attribute_restriction(*)
    where(link_type: :wiki_link)
  end

  def self.searchable_includes
    [:model, :linked_wiki, :linked_tag]
  end

  def self.available_includes
    [:model, :linked_wiki, :linked_tag]
  end
end
