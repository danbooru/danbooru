class DtextLink < ApplicationRecord
  belongs_to :model, polymorphic: true
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

  def self.model_matches(params)
    return all if params.blank?
    where(model_type: "WikiPage", model_id: WikiPage.search(params).reorder(nil))
  end

  def self.linked_wiki_exists(exists = true)
    dtext_links = DtextLink.arel_table
    wiki_pages = WikiPage.arel_table
    wiki_exists = wiki_pages.project(1).where(wiki_pages[:is_deleted].eq(false)).where(wiki_pages[:title].eq(dtext_links[:link_target])).exists

    if exists
      where(link_type: :wiki_link).where(wiki_exists)
    else
      where(link_type: :wiki_link).where.not(wiki_exists)
    end
  end

  def self.linked_tag_exists(exists = true)
    dtext_links = DtextLink.arel_table
    tags = Tag.arel_table
    tag_exists = tags.project(1).where(tags[:post_count].gt(0)).where(tags[:name].eq(dtext_links[:link_target])).exists

    if exists
      where(link_type: :wiki_link).where(tag_exists)
    else
      where(link_type: :wiki_link).where.not(tag_exists)
    end
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :model_type, :model_id, :link_type, :link_target)

    q = q.model_matches(params[:model])
    q = q.linked_wiki_exists(params[:linked_wiki_exists].truthy?) if params[:linked_wiki_exists].present?
    q = q.linked_tag_exists(params[:linked_tag_exists].truthy?) if params[:linked_tag_exists].present?

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

  def self.available_includes
    [:model]
  end
end
