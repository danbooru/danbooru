class WikiPageVersion < ApplicationRecord
  array_attribute :other_names
  belongs_to :wiki_page
  belongs_to_updater
  belongs_to :artist, optional: true
  belongs_to :tag, primary_key: :name, foreign_key: :title, optional: true

  module SearchMethods
    def search(params)
      q = super

      q = q.search_attributes(params, :title, :body, :other_names, :is_locked, :is_deleted)
      q = q.text_attribute_matches(:title, params[:title_matches])
      q = q.text_attribute_matches(:body, params[:body_matches])

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

  def subsequent
    @subsequent ||= begin
      WikiPageVersion.where("wiki_page_id = ? and id > ?", wiki_page_id, id).order("id asc").limit(1).to_a
    end
    @subsequent.first
  end

  def current
    @current ||= begin
      WikiPageVersion.where("wiki_page_id = ?", wiki_page_id).order("id desc").limit(1).to_a
    end
    @current.first
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

  def other_names_changed(type)
    other = self.send(type)
    ((other_names - other.other_names) | (other.other_names - other_names)).length.positive?
  end

  def was_deleted(type)
    other = self.send(type)
    if type == "previous"
      is_deleted && !other.is_deleted
    else
      !is_deleted && other.is_deleted
    end
  end

  def was_undeleted(type)
    other = self.send(type)
    if type == "previous"
      !is_deleted && other.is_deleted
    else
      is_deleted && !other.is_deleted
    end
  end

  def self.searchable_includes
    [:updater, :wiki_page, :artist, :tag]
  end

  def self.available_includes
    [:updater, :wiki_page, :artist, :tag]
  end
end
