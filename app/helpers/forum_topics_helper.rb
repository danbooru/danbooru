# frozen_string_literal: true

module ForumTopicsHelper
  def new_forum_topic?(topic, read_forum_topics)
    read_forum_topics.map(&:id).exclude?(topic.id)
  end

  def forum_topic_status(topic)
    if topic.bulk_update_requests.any?(&:is_pending?)
      :pending
    elsif topic.category == "Tags" && topic.bulk_update_requests.present? && topic.bulk_update_requests.all?(&:is_approved?)
      :approved
    elsif topic.category == "Tags" && topic.bulk_update_requests.present? && topic.bulk_update_requests.all?(&:is_rejected?)
      :rejected
    else
      nil
    end
  end

  def forum_post_vote_icon(vote)
    case vote.score
    when 1
      upvote_icon
    when -1
      downvote_icon
    else
      meh_icon
    end
  end
end
