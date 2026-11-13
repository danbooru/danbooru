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

  def visible(relation)
    if user.is_moderator?
      relation.where(user: User.where(level: ...user.level).or(User.where(id: user.id)))
    elsif user.is_anonymous?
      relation.none
    else
      relation.where(user: user)
    end
  end

  def searchable_attributes
    attributes = %i[id created_at updated_at category user ip_addr metadata ip_geolocation]

    if can_see_session?
      attributes + [:user_agent, { session_id: :exact }]
    else
      attributes
    end
  end

  def api_attributes
    attributes = super
    attributes -= [:session_id, :user_agent] unless can_see_session?
    attributes
  end
end
