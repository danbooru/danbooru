# frozen_string_literal: true

class UserEventPolicy < ApplicationPolicy
  def index?
    true
  end

  def can_see_events_by_others?
    user.is_moderator?
  end

  def can_see_session?
    user.is_moderator?
  end

  def searchable_attributes
    [:id, :created_at, :updated_at, :category, :user, :ip_addr, :user_agent, :metadata, :ip_geolocation, { session_id: :exact }]
  end

  def api_attributes
    attributes = super
    attributes -= [:session_id, :user_agent] unless can_see_session?
    attributes
  end
end
