class ArtistCommentaryVersion < ApplicationRecord
  belongs_to :post
  belongs_to_updater

  def self.text_matches(query)
    query = "*#{query}*" unless query =~ /\*/

    where_ilike(:original_title, query)
      .or(where_ilike(:original_description, query))
      .or(where_ilike(:translated_title, query))
      .or(where_ilike(:translated_description, query))
  end

  def self.search(params)
    q = super
    q = q.search_attributes(params, :original_title, :original_description, :translated_title, :translated_description)

    if params[:text_matches].present?
      q = q.text_matches(params[:text_matches])
    end

    q.apply_default_order(params)
  end

  def previous
    @previous ||= begin
      ArtistCommentaryVersion.where("post_id = ? and updated_at < ?", post_id, updated_at).order("updated_at desc").limit(1).to_a
    end
    @previous.first
  end

  def subsequent
    @subsequent ||= begin
      ArtistCommentaryVersion.where("post_id = ? and updated_at > ?", post_id, updated_at).order("updated_at asc").limit(1).to_a
    end
    @subsequent.first
  end

  def current
    @current ||= begin
      ArtistCommentaryVersion.where("post_id = ?", post_id).order("updated_at desc").limit(1).to_a
    end
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

  def self.searchable_includes
    [:post, :updater]
  end

  def self.available_includes
    [:post, :updater]
  end
end
