module TagRelationshipRetirementService
  THRESHOLD = 2.year

  extend self

  def forum_topic_title
    return "Retired tag aliases & implications"
  end

  def forum_topic_body
    return "This topic deals with tag relationships created two or more years ago that have not been used since. They will be retired. This topic will be updated as an automated system retires expired relationships."
  end

  def dry_run
    [TagAlias, TagImplication].each do |model|
      each_candidate(model) do |rel|
        puts "#{rel.relationship} #{rel.antecedent_name} -> #{rel.consequent_name} retired"
      end
    end
  end

  def forum_topic
    topic = ForumTopic.where(title: forum_topic_title).first
    if topic.nil?
      topic = CurrentUser.as_system do
        ForumTopic.create(title: forum_topic_title, category_id: 1, original_post_attributes: {body: forum_topic_body})
      end
    end
    return topic
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

    # model.active.where("created_at < ?", SMALL_THRESHOLD.ago).find_each do |rel|
    #   if is_underused?(rel.consequent_name)
    #     yield(rel)
    #   end
    # end
  end

  def is_underused?(name)
    (Tag.find_by_name(name).try(:post_count) || 0) < COUNT_THRESHOLD
  end

  def is_unused?(name)
    return !Post.tag_match("status:any #{name}").where("created_at > ?", THRESHOLD.ago).exists?
  end
end
