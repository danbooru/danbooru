module TagRelationshipRetirementService
  module_function

  THRESHOLD = 2.years

  def forum_topic_title
    "Retired tag aliases & implications"
  end

  def forum_topic_body
    "This topic deals with tag relationships created two or more years ago that have not been used since. They will be retired. This topic will be updated as an automated system retires expired relationships."
  end

  def forum_topic
    topic = ForumTopic.where(title: forum_topic_title).first
    if topic.nil?
      CurrentUser.as(User.system) do
        topic = ForumTopic.create!(creator: User.system, title: forum_topic_title, category_id: 1)
        forum_post = ForumPost.create!(creator: User.system, body: forum_topic_body, topic: topic)
      end
    end
    topic
  end

  def find_and_retire!
    messages = []

    [TagAlias, TagImplication].each do |model|
      each_candidate(model) do |rel|
        rel.update(status: "retired")
        messages << rel.retirement_message
      end
    end

    updater = ForumUpdater.new(forum_topic)
    updater.update(messages.sort.join("\n"))
  end

  def each_candidate(model)
    model.active.where("created_at < ?", THRESHOLD.ago).find_each do |rel|
      if is_unused?(rel.consequent_name)
        yield(rel)
      end
    end
  end

  def is_unused?(name)
    !Post.raw_tag_match(name).where("created_at > ?", THRESHOLD.ago).exists?
  end
end
