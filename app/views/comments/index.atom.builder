atom_feed(root_url: comments_url(host: Danbooru.config.hostname)) do |feed|
  title = "Comments"
  title += " by #{params[:search][:creator_name]}" if params.dig(:search, :creator_name).present?
  title += " on #{params[:search][:post_tags_match]}" if params.dig(:search, :post_tags_match).present?
  title += " on post ##{params[:search][:post_id]}" if params.dig(:search, :post_id).present?

  feed.title(title)
  feed.updated(@comments.first.try(:updated_at))

  @comments.each do |comment|
    feed.entry(comment, published: comment.created_at, updated: comment.updated_at) do |entry|
      entry.title("@#{comment.creator.name} on post ##{comment.post_id} (#{comment.post.presenter.humanized_essential_tag_string})")
      entry.content(<<-EOS.strip_heredoc, type: "html")
        <img src="#{comment.post.preview_file_url}"/>

        #{format_text(comment.body)}
      EOS

      entry.author do |author|
        author.name(comment.creator.name)
        author.uri(user_url(comment.creator))
      end
    end
  end
end
