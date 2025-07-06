# frozen_string_literal: true

class ForumTopicPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.level >= record.min_level_id
  end

  def update?
    unbanned? && show? && (user.is_moderator? || (record.creator_id == user.id && !record.is_locked?))
  end

  def destroy?
    unbanned? && show? && user.is_moderator?
  end

  def undelete?
    unbanned? && show? && user.is_moderator?
  end

  def mark_all_as_read?
    !user.is_anonymous?
  end

  def reply?
    show? && (user.is_moderator? || !record.is_locked?)
  end

  def moderate?
    user.is_moderator?
  end

  def rate_limit_for_create(**_options)
    if record.invalid?
      { action: "forum_topics:create:invalid", rate: 1.0 / 1.second, burst: 5 }
    elsif user.forum_topics.exists?(created_at: ..24.hours.ago)
      { rate: 1.0 / 1.minute, burst: 2 }
    else
      { rate: 1.0 / 3.minutes, burst: 1 }
    end
  end

  def permitted_attributes
    [
      :title, :category, :category_id, { original_post_attributes: [:id, :body] },
      ([:is_sticky, :is_locked, :min_level] if moderate?),
    ].compact.flatten
  end

  def html_data_attributes
    super + [:is_read?]
  end
end
