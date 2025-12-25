# frozen_string_literal: true

class ForumPostPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    policy(record.topic).show?
  end

  def create?
    unbanned? && policy(record.topic).reply?
  end

  def update?
    unbanned? && show? && (user.is_moderator? || (record.creator_id == user.id && !record.topic.is_locked?))
  end

  def destroy?
    unbanned? && show? && !record.is_deleted? && user.is_moderator?
  end

  def undelete?
    unbanned? && show? && record.is_deleted? && !record.topic.is_deleted? && user.is_moderator?
  end

  def reply?
    policy(record.topic).reply?
  end

  def votable?
    unbanned? && show? && record.bulk_update_request.present? && record.bulk_update_request.is_pending?
  end

  def reportable?
    unbanned? && show? && record.creator_id != user.id && !record.creator.is_moderator? && record.created_at.after?(1.year.ago)
  end

  def show_deleted?
    !record.is_deleted? || user.is_moderator?
  end

  def can_see_updater_notice?
    user.is_moderator?
  end

  def rate_limit_for_create(**_options)
    if record.invalid?
      { action: "forum_posts:create:invalid", rate: 1.0 / 1.second, burst: 1 }
    elsif user.is_builder?
      { rate: 1.0 / 1.minute, burst: 10 }
    elsif user.forum_posts.exists?(created_at: ..24.hours.ago)
      { rate: 1.0 / 1.minute, burst: 3 }
    else
      { rate: 1.0 / 2.minutes, burst: 2 }
    end
  end

  def permitted_attributes_for_create
    [:body, :topic_id]
  end

  def permitted_attributes_for_update
    [:body]
  end

  def html_data_attributes
    super + [[:topic, :is_deleted?]]
  end
end
