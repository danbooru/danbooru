atom_feed(root_url: forum_topic_url(@forum_topic)) do |feed|
  feed.title(@forum_topic.title)
  feed.updated(@forum_topic.try(:updated_at))
  dtext_references = DText.preprocess(@forum_posts.map(&:body))

  @forum_posts.each do |post|
    feed.entry(post, published: post.created_at, updated: post.updated_at) do |entry|
      html = post.dtext_body.format_text(references: dtext_references)
      entry.title("@#{post.creator.name}: #{post.dtext_body.excerpt(length: 50, separator: /[[:space:]]/, html:)}")
      entry.content(html, type: "html")

      entry.author do |author|
        author.name(post.creator.name)
        author.uri(user_url(post.creator))
      end
    end
  end
end
