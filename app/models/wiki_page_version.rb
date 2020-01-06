class WikiPageVersion < ApplicationRecord
  array_attribute :other_names
  belongs_to :wiki_page
  belongs_to_updater
  belongs_to :artist, optional: true
  delegate :visible?, :to => :wiki_page

  module SearchMethods
    def search(params)
      q = super

      q = q.search_attributes(params, :updater, :is_locked, :is_deleted, :wiki_page_id)
      q = q.text_attribute_matches(:title, params[:title])
      q = q.text_attribute_matches(:body, params[:body])

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def pretty_title
    title.tr("_", " ")
  end

  def previous
    WikiPageVersion.where("wiki_page_id = ? and id < ?", wiki_page_id, id).order("id desc").first
  end

  def category_name
    Tag.category_for(title)
  end
end
