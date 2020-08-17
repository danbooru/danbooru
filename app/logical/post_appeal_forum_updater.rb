module PostAppealForumUpdater
  APPEAL_TOPIC_TITLE = "Deletion appeal thread"

  def self.update_forum!
    return if pending_appeals.empty?

    CurrentUser.scoped(User.system) do
      topic = ForumTopic.order(:id).create_with(creator: User.system).find_or_create_by!(title: APPEAL_TOPIC_TITLE)
      ForumPost.create!(creator: User.system, topic: topic, body: forum_post_body)
    end
  end

  def self.pending_appeals
    PostAppeal.pending.where(created_at: (1.hour.ago..Time.zone.now)).order(post_id: :asc)
  end

  def self.forum_post_body
    pending_appeals.map do |appeal|
      if appeal.reason.present?
        "post ##{appeal.post_id}: #{appeal.reason}"
      else
        "post ##{appeal.post_id}"
      end
    end.join("\n")
  end
end
