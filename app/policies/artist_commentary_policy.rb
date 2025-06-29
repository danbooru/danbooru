# frozen_string_literal: true

class ArtistCommentaryPolicy < ApplicationPolicy
  def create_or_update?
    unbanned?
  end

  def revert?
    unbanned?
  end

  def rate_limit_for_write(**_options)
    if record.invalid?
      { action: "artist_commentaries:write:invalid", rate: 1.0 / 1.second, burst: 1 }
    elsif user.artist_commentary_versions.exists?(post: record, created_at: 1.hour.ago..)
      { action: "artist_commentaries:write:artist-commentary-#{record.id}", rate: 4.0 / 1.minute, burst: 10 } # 240 per hour, 250 in first hour
    elsif user.is_builder?
      { action: "artist_commentaries:write", rate: 24.0 / 1.minute, burst: 60 } # 1440 per hour, 1500 in first hour
    elsif user.artist_commentary_versions.exists?(created_at: ..24.hours.ago)
      { action: "artist_commentaries:write", rate: 4.0 / 1.minute, burst: 30 } # 240 per hour, 300 in first hour
    else
      { action: "artist_commentaries:write", rate: 1.0 / 1.minute, burst: 20 } # 60 per hour, 80 in first hour
    end
  end

  def permitted_attributes
    %i[
      original_description original_title
      translated_description translated_title
      remove_commentary_tag remove_commentary_request_tag
      remove_commentary_check_tag remove_partial_commentary_tag
      add_commentary_tag add_commentary_request_tag
      add_commentary_check_tag add_partial_commentary_tag
    ]
  end
end
