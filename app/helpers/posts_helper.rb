module PostsHelper
  def resize_image_links(post, user)
    links = []
    
    links << %{<a href="#" data-src="#{post.file_url}" data-width="#{post.image_width}" data-height="#{post.image_height}">Original</a>} if post.has_medium? || post.has_large?
    links << %{<a href="#" data-src="#{post.medium_file_url}" data-width="#{post.medium_image_width}" data-height="#{post.medium_image_height}">Medium</a>} if post.has_medium?
    links << %{<a href="#" data-src="#{post.large_file_url}" data-width="#{post.large_image_width}" data-height="#{post.large_image_height}">Large</a>} if post.has_large?
    
    if links.any?
      html = %{<li id="resize-link"><a href="#">Resize</a></li><ul id="resize-links">} + links.map {|x| %{<li>#{x}</li>}}.join("") + %{</ul>}
      html.html_safe
    else
      ""
    end
  end
end
