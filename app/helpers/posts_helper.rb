module PostsHelper
  def image_dimensions(post, current_user)
    if post.is_image?
      "(#{post.image_width_for(current_user)}x#{post.image_height_for(current_user)})"
    else
      ""
    end
  end
  
  def image_dimension_menu(post, current_user)
    html = ""
    file_size = number_to_human_size(post.file_size)
    original_dimensions = post.is_image? ? "(#{post.image_width}x#{post.image_height})" : nil
    large_dimensions = post.has_large? ? "(#{post.large_image_width}x#{post.large_image_height})" : nil
    medium_dimensions = post.has_medium? ? "(#{post.medium_image_width}x#{post.medium_image_height})" : nil
    current_dimensions = "(#{post.image_width_for(current_user)}x#{post.image_height_for(current_user)})"
    html << %{<menu type="context" data-user-default="<%= current_user.default_image_size %>">}
    html << %{<li>#{file_size} #{current_dimensions}</li>}
    html << %{<ul>}
    html << %{<li id="original">#{file_size} #{original_dimensions}</li>}
    html << %{<li id="medium">#{file_size} #{medium_dimensions}</li>} if medium_dimensions
    html << %{<li id="large">#{file_size} #{large_dimensions}</li>} if large_dimensions
    html << %{</ul>}
    html << %{</menu>}
    html.html_safe
  end
end
