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
      source_search = "source:#{text}/"
    elsif post.source =~ %r!http://i\d\.pixiv\.net/img\d+/img/([^\/]+)/!
      text = "pixiv/#{$1}"
      source_link = link_to(text, post.normalized_source)
      source_search = "source:#{text}/"
    elsif post.source =~ /^http/
      text = truncate(post.normalized_source.sub(/^https?:\/\/(?:www\.)?/, ""))
      source_link = link_to(truncate(text, :length => 20), post.normalized_source)
      source_search = "source:#{post.source.sub(/[^\/]*$/, "")}"
    else
      source_link = truncate(post.source, :length => 100)
    end

    if CurrentUser.is_builder? && !source_search.blank?
      source_link + "&nbsp;".html_safe + link_to("&raquo;".html_safe, posts_path(:tags => source_search))
    else
      source_link
    end
  end

  def has_parent_message(post, parent_post_set, siblings_post_set)
    html = ""

    html << "This post belongs to a "
    html << link_to("parent", post_path(post.parent_id))
    html << " (deleted)" if parent_post_set.posts.first.is_deleted?

    if siblings_post_set.posts.count > 1
      html << " and has "
      text = siblings_post_set.posts.count > 2 ? "#{siblings_post_set.posts.count - 1} siblings" : "a sibling"
      html << link_to(text, posts_path(:tags => "parent:#{post.parent_id}"))
    end

    html << " (#{link_to("learn more", wiki_pages_path(:title => "help:post_relationships"))}) "

    html << link_to("show &raquo;".html_safe, "#", :id => "has-parent-relationship-preview-link")

    html.html_safe
  end

  def has_children_message(post, children_post_set)
    html = ""

    html << "This post has "
    text = children_post_set.posts.count == 1 ? "a child" : "#{children_post_set.posts.count} children"
    html << link_to(text, posts_path(:tags => "parent:#{post.id}"))

    html << " (#{link_to("learn more", wiki_pages_path(:title => "help:post_relationships"))}) "

    html << link_to("show &raquo;".html_safe, "#", :id => "has-children-relationship-preview-link")

    html.html_safe
  end
end
