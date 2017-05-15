atom_feed do |feed|
  feed.title(@forum_topic.title)
  feed.updated(@forum_topic.try(:updated_at))

  @forum_posts.each do |post|
    feed.entry(post, published: post.created_at, updated: post.updated_at) do |entry|
      entry.title("@#{post.creator.name}: #{strip_dtext(post.body).truncate(50, separator: /[[:space:]]/)}")
      entry.content(format_text(post.body), type: "html")

      entry.author do |author|
        author.name(post.creator.name)
        author.uri(user_url(post.creator))
      end
    end
  end
end
