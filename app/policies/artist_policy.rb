# frozen_string_literal: true

class ArtistPolicy < ApplicationPolicy
  def ban?
    user.is_admin? && !record.is_banned?
  end

  def unban?
    user.is_admin? && record.is_banned?
  end

  def revert?
    unbanned?
  end

  def can_view_banned?
    !user.is_anonymous?
  end

  def rate_limit_for_index(**_options)
    if user.is_anonymous?
      { rate: 1.0 / 1.second, burst: 30 }
    else
      { rate: 2.0 / 1.second, burst: 40 }
    end
  end

  # Whether the user can see posts when searching for a banned artist.
  def can_search_banned?
    user.is_approver?
  end

  def rate_limit_for_write(**_options)
    if user.is_builder?
      { action: "artists:write", rate: 12.0 / 1.minute, burst: 80 } # 720 per hour, 800 in first hour
    elsif user.artist_versions.exists?(created_at: ..24.hours.ago)
      { action: "artists:write", rate: 2.0 / 1.minute, burst: 30 } # 120 per hour, 150 in first hour
    else
      { action: "artists:write", rate: 1.0 / 1.5.minutes, burst: 10 } # 40 per hour, 50 in first hour
    end
  end

  def permitted_attributes
    [:name, :other_names, :other_names_string, :group_name, :url_string, :is_deleted]
  end

  def permitted_attributes_for_new
    permitted_attributes + [:source]
  end

  alias_method :show_or_new?, :show?

  def searchable_attributes
    %i[id created_at updated_at is_deleted is_banned name group_name other_names urls wiki_page tag_alias tag]
  end
end
