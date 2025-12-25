# frozen_string_literal: true

class UploadPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def show?
    user.is_admin? || record.uploader_id == user.id
  end

  def rate_limit_for_create(**_options)
    if record.invalid?
      { action: "uploads:create:invalid", rate: 1.0 / 1.second, burst: 1 }
    elsif user.is_builder?
      { action: "uploads:create", rate: 24.0 / 1.minute, burst: 60 } # 1440 per hour, 1500 in first hour
    elsif user.posts.active.exists?(created_at: ..4.hours.ago)
      { action: "uploads:create", rate: 8.0 / 1.minute, burst: 60 } # 480 per hour, 540 in first hour
    elsif user.posts.exists?(created_at: ..4.hours.ago)
      { action: "uploads:create", rate: 4.0 / 1.minute, burst: 30 } # 240 per hour, 270 in first hour
    elsif user.uploads.completed.exists?(created_at: ..4.hours.ago)
      { action: "uploads:create", rate: 2.0 / 1.minute, burst: 15 } # 120 per hour, 135 in first hour
    else
      { action: "uploads:create", rate: 1.0 / 1.minute, burst: 10 } # 60 per hour, 70 in first hour
    end
  end

  def permitted_attributes
    [:source, :referer_url, files: {}]
  end
end
