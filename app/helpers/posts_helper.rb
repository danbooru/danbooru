module PostsHelper
  def resize_image_links(post, user)
    links = []

    if post.has_large?
      links << link_to("L", post.large_file_url, :id => "large-file-link")
    end

    if post.has_large?
      links << link_to("O", post.file_url, :id => "original-file-link")
    end

    if links.any?
      content_tag("span", raw("Resize: " + links.join(" ")))
    else
      nil
    end
  end

  def post_source_tag(post)
    if post.source =~ %r!http://img\d+\.pixiv\.net/img/([^\/]+)/!
      text = "pixiv/#{$1}"
      source_link = link_to(text, post.normalized_source)
      source_search = "source:#{text}"
    elsif post.source =~ %r!http://i\d\.pixiv\.net/img\d+/img/([^\/]+)/!
      text = "pixiv/#{$1}"
      source_link = link_to(text, post.normalized_source)
      source_search = "source:#{text}"
    elsif post.source =~ /^http/
      text = truncate(post.normalized_source.sub(/^https?:\/\/(?:www)?/, ""))
      source_link = link_to(truncate(text, :length => 20), post.normalized_source)
      source_search = "source:#{post.source.sub(/[^\/]*$/, "")}"
    else
      source_link = truncate(post.source, :length => 100)
    end

    if CurrentUser.is_builder? && !source_search.blank?
      source_link + " " + link_to("&raquo;".html_safe, posts_path(:tags => source_search))
    else
      source_link
    end
  end
end
