# frozen_string_literal: true

class UserEventPolicy < ApplicationPolicy
  def index?
    true
  end

  def fingerprint?
    user.is_moderator?
  end

  def compare_fingerprint?
    fingerprint?
  end

  def can_see_events_by_others?
    user.is_moderator?
  end

  def can_see_session?
    user.is_moderator?
  end

  def api_attributes
    attributes = super
    attributes -= [:session_id, :user_agent, :fingerprint, :fingerprint_hash] unless can_see_session?
    attributes
  end
end
