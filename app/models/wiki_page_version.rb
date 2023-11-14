# frozen_string_literal: true

class WikiPageVersion < ApplicationRecord
  array_attribute :other_names
  belongs_to :wiki_page
  belongs_to_updater
  belongs_to :tag, primary_key: :name, foreign_key: :title, optional: true

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :title, :body, :other_names, :is_locked, :is_deleted, :updater, :wiki_page, :tag], current_user: current_user)

      q.apply_default_order(params)
    end
  end

  extend SearchMethods

  def pretty_title
    title.tr("_", " ")
  end

  def previous
    @previous ||= WikiPageVersion.where("wiki_page_id = ? and id < ?", wiki_page_id, id).order("id desc").limit(1).to_a
    @previous.first
  end

  def current
    @current ||= WikiPageVersion.where(wiki_page_id: wiki_page_id).order("id desc").limit(1).to_a
    @current.first
  end

  def self.status_fields
    {
      body: "Body",
      other_names_changed: "OtherNames",
      title: "Renamed",
      was_deleted: "Deleted",
      was_undeleted: "Undeleted",
      was_locked: "Locked",
      was_unlocked: "Unlocked",
    }
  end

  def other_names_changed(type)
    other = send(type)
    ((other_names - other.other_names) | (other.other_names - other_names)).length.positive?
  end

  def was_deleted(type)
    other = send(type)
    if type == "previous"
      is_deleted && !other.is_deleted
    else
      !is_deleted && other.is_deleted
    end
  end

  def was_undeleted(type)
    other = send(type)
    if type == "previous"
      !is_deleted && other.is_deleted
    else
      is_deleted && !other.is_deleted
    end
  end

  def was_locked(type)
    other = send(type)
    if type == "previous"
      is_locked && !other.is_locked
    else
      !is_locked && other.is_locked
    end
  end

  def was_unlocked(type)
    other = send(type)
    if type == "previous"
      !is_locked && other.is_locked
    else
      is_locked && !other.is_locked
    end
  end

  def self.available_includes
    [:updater, :wiki_page, :tag]
  end
end
