class DtextLink < ApplicationRecord
  belongs_to :model, polymorphic: true
  enum link_type: [:wiki_link, :external_link]

  before_validation :normalize_link_target
  validates :link_target, uniqueness: { scope: [:model_type, :model_id] }

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

  def normalize_link_target
    if wiki_link?
      self.link_target = WikiPage.normalize_title(link_target)
    end
  end
end
