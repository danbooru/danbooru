#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  CurrentUser.scoped(User.system) do
    # delete all posts in deleted topics
    ForumPost.undeleted.where(topic: ForumTopic.deleted).update_all(is_deleted: true, updated_at: Time.zone.now, updater_id: User.system.id)

    # undelete all deleted OPs in active topics
    ForumPost.deleted.where(topic: ForumTopic.undeleted).find_each do |forum_post|
      if forum_post.is_original_post?
        forum_post.update_columns(is_deleted: false, updated_at: Time.zone.now, updater_id: User.system.id)
      end
    end
  end
end
