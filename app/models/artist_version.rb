class ArtistVersion < ApplicationRecord
  array_attribute :urls
  array_attribute :other_names

  belongs_to_updater
  belongs_to :artist

  module SearchMethods
    def search(params)
      q = super

      q = q.search_attributes(params, :updater, :is_active, :is_banned, :artist_id, :name, :group_name)

      if params[:order] == "name"
        q = q.order("artist_versions.name").default_order
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  extend SearchMethods

  def previous
    @previous ||= begin
      ArtistVersion.where("artist_id = ? and created_at < ?", artist_id, created_at).order("created_at desc").limit(1).to_a
    end
    @previous.first
  end

  def self.status_fields
    {
      name: "Renamed",
      urls_changed: "URLs",
      other_names_changed: "OtherNames",
      group_name: "GroupName",
      was_deleted: "Deleted",
      was_undeleted: "Undeleted",
      was_banned: "Banned",
      was_unbanned: "Unbanned",
    }
  end

  def other_names_changed
    ((other_names - previous.other_names) | (previous.other_names - other_names)).length > 0
  end

  def urls_changed
    ((urls - previous.urls) | (previous.urls - urls)).length > 0
  end

  def was_deleted
    !is_active && previous.is_active
  end

  def was_undeleted
    is_active && !previous.is_active
  end

  def was_banned
    is_banned && !previous.is_banned
  end

  def was_unbanned
    !is_banned && previous.is_banned
  end

  def self.available_includes
    [:updater, :artist]
  end
end
