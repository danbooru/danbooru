# frozen_string_literal: true

# Removes inactive aliases and implications. 'Inactive' means aliases to empty
# tags, implications from empty tags, and gentag and artist aliases that
# haven't had any new posts in the last two years.
#
# Runs weekly. Posts a message to the forum when aliases or implications are
# retired.
#
# @see DanbooruMaintenance#weekly
module TagRelationshipRetirementService
  module_function

  THRESHOLD = 2.years

  FORUM_TOPIC_TITLE = "Retired tag aliases & implications"
  FORUM_TOPIC_BODY = "This topic deals with tag relationships created two or more years ago that have not been used since. They will be retired. This topic will be updated as an automated system retires expired relationships."

  def forum_topic
    topic = ForumTopic.where(title: FORUM_TOPIC_TITLE).first
    if topic.nil?
      CurrentUser.scoped(User.system) do
        topic = ForumTopic.create!(creator: User.system, title: FORUM_TOPIC_TITLE, category_id: 1)
        ForumPost.create!(creator: User.system, body: FORUM_TOPIC_BODY, topic: topic)
      end
    end
    topic
  end

  def find_and_retire!
    messages = []

    inactive_relationships.each do |rel|
      rel.update!(status: "retired")
      messages << "The #{rel.relationship} [[#{rel.antecedent_name}]] -> [[#{rel.consequent_name}]] has been retired."
    end

    updater = ForumUpdater.new(forum_topic)
    updater.update(messages.sort.join("\n"))
  end

  def inactive_relationships
    (inactive_aliases + TagAlias.active.empty + TagImplication.active.empty).uniq
  end

  def inactive_aliases
    aliases = TagAlias.general.or(TagAlias.artist).active.where("tag_aliases.created_at < ?", THRESHOLD.ago)
    aliases.select do |tag_alias|
      !tag_alias.consequent_tag.posts.exists?(["created_at > ?", THRESHOLD.ago])
    end
  end
end
