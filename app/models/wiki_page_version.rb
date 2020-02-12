class WikiPageVersion < ApplicationRecord
  array_attribute :other_names
  belongs_to :wiki_page
  belongs_to_updater
  belongs_to :artist, optional: true

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
    @previous ||= begin
      WikiPageVersion.where("wiki_page_id = ? and id < ?", wiki_page_id, id).order("id desc").limit(1).to_a
    end
    @previous.first
  end

  def self.status_fields
    {
      body: "Body",
      other_names_changed: "OtherNames",
      title: "Renamed",
      was_deleted: "Deleted",
      was_undeleted: "Undeleted",
    }
  end

  def other_names_changed
    ((other_names - previous.other_names) | (previous.other_names - other_names)).length > 0
  end

  def was_deleted
    is_deleted && !previous.is_deleted
  end

  def was_undeleted
    !is_deleted && previous.is_deleted
  end

  def category_name
    Tag.category_for(title)
  end

  def self.available_includes
    [:updater, :wiki_page, :artist]
  end
end
