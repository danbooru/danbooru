module ForumTopicsHelper
  def forum_topic_category_select(object, field)
    select(object, field, ForumTopic.reverse_category_mapping.to_a)
  end

  def available_min_user_levels
    ForumTopic::MIN_LEVELS.select { |name, level| level <= CurrentUser.level }.to_a
  end

  def new_forum_topic?(topic, read_forum_topics)
    !read_forum_topics.map(&:id).include?(topic.id)
  end
end
