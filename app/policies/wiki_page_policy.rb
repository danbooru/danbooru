# frozen_string_literal: true

class WikiPagePolicy < ApplicationPolicy
  def show_or_new?
    true
  end

  def update?
    unbanned? && (can_edit_locked? || !record.is_locked?)
  end

  def revert?
    update?
  end

  def can_edit_locked?
    user.is_builder?
  end

  def can_see_updater_notice?
    user.is_moderator?
  end

  def new_editor?
    !user.wiki_page_versions.exists?(created_at: ..24.hours.ago)
  end

  def is_large_tag?
    Tag.where(name: record.title).exists?(name: Tag.order(post_count: :desc).limit(500).select(:name))
  end

  def rate_limit_for_write(**_options)
    if record.invalid?
      { action: "wiki_pages:write:invalid", rate: 1.0 / 1.second, burst: 1 }
    elsif user.wiki_page_versions.exists?(wiki_page: record, created_at: 1.hour.ago..)
      { action: "wiki_pages:write:wiki-page-#{record.id}", rate: 4.0 / 1.minute, burst: 10 } # 240 per hour, 250 in first hour
    elsif user.is_builder?
      { action: "wiki_pages:write", rate: 8.0 / 1.minute, burst: 120 } # 480 per hour, 600 in first hour
    elsif !new_editor?
      { action: "wiki_pages:write", rate: 2.0 / 1.minute, burst: 30 } # 120 per hour, 150 in first hour
    elsif is_large_tag? && new_editor?
      { action: "wiki_pages:write:large", rate: 1.0 / 1.5.minutes, burst: 1 } # 40 per hour, 40 in first hour
    else
      { action: "wiki_pages:write", rate: 1.0 / 1.5.minutes, burst: 10 } # 40 per hour, 50 in first hour
    end
  end

  def permitted_attributes
    [:title, :body, :other_names, :other_names_string, :is_deleted, (:is_locked if can_edit_locked?)].compact
  end
end
