# frozen_string_literal: true

class DmailPolicy < ApplicationPolicy
  def create?
    unbanned?
  end

  def index?
    !user.is_anonymous?
  end

  def mark_all_as_read?
    !user.is_anonymous?
  end

  def update?
    !user.is_anonymous? && record.owner_id == user.id
  end

  def show?
    return true if user.is_owner?
    !user.is_anonymous? && record.owner_id == user.id
  end

  def reportable?
    unbanned? && record.owner_id == user.id && record.is_recipient? && !record.is_automated? && !record.from.is_moderator? && record.created_at.after?(1.year.ago)
  end

  def rate_limit_for_create(**_options)
    if user.is_builder?
      { action: "dmails:create", rate: 4.0 / 1.minute, burst: 60 } # 240 per hour, 300 in first hour
    elsif user.dmails.sent.exists?(created_at: ..24.hours.ago)
      { action: "dmails:create", rate: 1.0 / 1.minute, burst: 5 } # 60 per hour, 65 in first hour
    else
      { action: "dmails:create", rate: 1.0 / 2.minutes, burst: 5 } # 30 per hour, 35 in first hour
    end
  end

  def permitted_attributes_for_create
    [:title, :body, :to_name, :to_id]
  end

  def permitted_attributes_for_update
    [:is_read, :is_deleted]
  end

  def api_attributes
    super + [:key]
  end
end
