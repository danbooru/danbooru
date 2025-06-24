# frozen_string_literal: true

class NotePolicy < ApplicationPolicy
  def preview?
    true
  end

  def revert?
    update?
  end

  def rate_limit_for_preview(**_options)
    {}
  end

  def rate_limit_for_write(**_options)
    if record.invalid?
      { action: "notes:write:invalid", rate: 5.0 / 1.second, burst: 5 }
    elsif user.note_versions.exists?(note: record, created_at: 1.hour.ago..)
      { action: "notes:write:note-#{record.id}", rate: 12.0 / 1.minute, burst: 80 } # 720 note edits per hour, 800 in first hour
    elsif user.note_versions.exists?(post: record.post, created_at: 1.hour.ago..) && user.is_builder?
      { action: "notes:write:post-#{record.post.id}", rate: 12.0 / 1.minute, burst: 80 } # 720 notes per post per hour, 800 in first hour
    elsif user.note_versions.exists?(post: record.post, created_at: 1.hour.ago..) && user.note_versions.exists?(created_at: ..24.hours.ago)
      { action: "notes:write:post-#{record.post.id}", rate: 4.0 / 1.minute, burst: 60 } # 240 notes per post per hour, 300 in first hour
    elsif user.note_versions.exists?(post: record.post, created_at: 1.hour.ago..)
      { action: "notes:write:post-#{record.post.id}", rate: 1.0 / 1.minute, burst: 30 } # 60 notes per post per hour, 90 in first hour
    elsif user.is_builder?
      { action: "notes:write", rate: 12.0 / 1.minute, burst: 60 } # 720 posts per hour, 800 in first hour
    elsif user.note_versions.exists?(created_at: ..24.hours.ago)
      { action: "notes:write", rate: 2.0 / 1.minute, burst: 30 } # 120 posts per hour, 150 in first hour
    else
      { action: "notes:write", rate: 1.0 / 1.5.minutes, burst: 10 } # 40 posts per hour, 50 in first hour
    end
  end

  def permitted_attributes_for_create
    [:x, :y, :width, :height, :body, :post_id, :html_id]
  end

  def permitted_attributes_for_update
    [:x, :y, :width, :height, :body]
  end
end
