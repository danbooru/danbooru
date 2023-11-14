# frozen_string_literal: true

class ArtistVersion < ApplicationRecord
  array_attribute :urls
  array_attribute :other_names

  belongs_to_updater
  belongs_to :artist

  def self.visible(user)
    if policy(user).can_view_banned?
      all
    else
      where(artist: Artist.unbanned)
    end
  end

  module SearchMethods
    def search(params, current_user)
      q = search_attributes(params, [:id, :created_at, :updated_at, :is_deleted, :is_banned, :name, :group_name, :urls, :other_names, :updater, :artist], current_user: current_user)

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
    @previous ||= ArtistVersion.where("artist_id = ? and created_at < ?", artist_id, created_at).order("created_at desc").limit(1).to_a
    @previous.first
  end

  def current
    @previous ||= ArtistVersion.where(artist_id: artist_id).order("created_at desc").limit(1).to_a
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

  def other_names_changed(type)
    other = send(type)
    ((other_names - other.other_names) | (other.other_names - other_names)).length.positive?
  end

  def urls_changed(type)
    other = send(type)
    ((urls - other.urls) | (other.urls - urls)).length.positive?
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

  def was_banned(type)
    other = send(type)
    if type == "previous"
      is_banned && !other.is_banned
    else
      !is_banned && other.is_banned
    end
  end

  def was_unbanned(type)
    other = send(type)
    if type == "previous"
      !is_banned && other.is_banned
    else
      is_banned && !other.is_banned
    end
  end

  def self.available_includes
    [:updater, :artist]
  end
end
