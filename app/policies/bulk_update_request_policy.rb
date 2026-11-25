# frozen_string_literal: true

class BulkUpdateRequestPolicy < ApplicationPolicy
  def show?
    if record.forum_post.present?
      policy(record.forum_post).show?
    elsif record.forum_topic.present?
      policy(record.forum_topic).show? && (!record.forum_topic.is_deleted? || user.is_moderator?)
    else
      true
    end
  end

  def create?
    unbanned? && (record.forum_topic.blank? || policy(record.forum_topic).reply?)
  end

  def update?
    return false if !unbanned? || !show? || record.is_approved?

    user.is_admin? || (record.user_id == user.id && !record.has_too_many_votes_to_edit?)
  end

  # A cheap estimate based on the tags' current state, used to show the Approve button and for the can_approve
  # search. The real check is done by `BulkUpdateRequest#approve!`, which checks each line after simulating the lines
  # before it, since an earlier line can change what a later line needs.
  def approve?(tags: nil)
    return false if !unbanned? || !show? || record.is_approved?

    user.level >= record.approval_level(tags:)
  end

  def destroy?(tags: nil)
    return false if !unbanned? || !show?
    return user.is_moderator? if record.is_queued?
    return false if record.is_approved?

    record.is_pending? && (record.user_id == user.id || (user.is_moderator? && approve?(tags:)))
  end

  def can_update_forum?
    user.is_admin?
  end

  def rate_limit_for_write(**_options)
    if record.invalid?
      { action: "bulk_update_requests:write:invalid", rate: 1.0 / 1.second, burst: 1 }
    elsif user.is_admin?
      { action: "bulk_update_requests:write", rate: 1.0 / 1.second, burst: 50 }
    elsif user.is_builder?
      { action: "bulk_update_requests:write", rate: 1.0 / 1.minute, burst: 20 }
    elsif user.bulk_update_requests.exists?(created_at: ..4.hours.ago)
      { action: "bulk_update_requests:write", rate: 1.0 / 1.minute, burst: 20 }
    else
      { action: "bulk_update_requests:write", rate: 1.0 / 1.minute, burst: 5 }
    end
  end

  def permitted_attributes_for_create
    [:script, :title, :reason, :forum_topic_id]
  end

  def permitted_attributes_for_update
    if can_update_forum?
      [:script, :forum_topic_id, :forum_post_id]
    else
      [:script]
    end
  end

  def visible(relation)
    visible_topics = user.is_moderator? ? ForumTopic.visible(user) : ForumTopic.visible(user).undeleted
    with_post = relation.where(forum_post: ForumPost.visible(user))
    without_post = relation.where(forum_post_id: nil, forum_topic: visible_topics)
    without_forum = relation.where(forum_post_id: nil, forum_topic_id: nil)

    with_post.or(without_post).or(without_forum)
  end

  def searchable_attributes
    %i[id created_at updated_at script tags user forum_topic forum_post approver]
  end
end
