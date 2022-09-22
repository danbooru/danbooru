# frozen_string_literal: true

class ArtistCommentaryVersion < ApplicationRecord
  belongs_to :post
  belongs_to_updater

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :original_title, :original_description, :translated_title, :translated_description, :post, :updater)
    q = q.where_text_matches(%i[original_title original_description translated_title translated_description], params[:text_matches])

    q.apply_default_order(params)
  end

  def previous
    @previous ||= ArtistCommentaryVersion.where("post_id = ? and updated_at < ?", post_id, updated_at).order("updated_at desc").limit(1).to_a
    @previous.first
  end

  def current
    @current ||= ArtistCommentaryVersion.where(post_id: post_id).order("updated_at desc").limit(1).to_a
    @current.first
  end

  def self.status_fields
    {
      original_title: "OrigTitle",
      original_description: "OrigDesc",
      translated_title: "TransTitle",
      translated_description: "TransDesc",
    }
  end

  def unchanged_empty?(field)
    self[field].strip.empty? && (previous.nil? || previous[field].strip.empty?)
  end

  def self.available_includes
    [:post, :updater]
  end
end
