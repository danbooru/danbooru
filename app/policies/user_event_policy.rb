# frozen_string_literal: true

class UserEventPolicy < ApplicationPolicy
  def index?
    true
  end

  def can_see_events_by_others?
    user.is_moderator?
  end

  def api_attributes
    attributes = super
    attributes -= [:session_id, :user_agent] unless user.is_moderator?
    attributes
  end
end
