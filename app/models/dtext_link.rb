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

  def self.model_matches(params)
    return all if params.blank?
    where(model_id: WikiPage.search(params).reorder(nil))
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :model_type, :model_id, :link_type, :link_target)
    q = q.model_matches(params[:model])
    q.apply_default_order(params)
  end

  def normalize_link_target
    if wiki_link?
      self.link_target = WikiPage.normalize_title(link_target)
    end
  end
end
