atom_feed(root_url: forum_topics_url) do |feed|
  feed.title("Forum Topics")
  feed.updated(@forum_topics.first.try(:updated_at))

  @forum_topics.each do |topic|
    feed.entry(topic, published: topic.created_at, updated: topic.updated_at) do |entry|
      entry.title("[#{topic.category_name}] #{topic.title}")
      entry.content(topic.original_post.dtext_body.format_text, type: "html")

      entry.author do |author|
        author.name(topic.creator.name)
        author.uri(user_url(topic.creator_id))
      end
    end
  end
end
