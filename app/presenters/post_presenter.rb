class PostPresenter < Presenter
  def initialize(post, current_user)
    @post = post
    @current_user = current_user
  end
  
  def tag_list_html
  end
  
  def image_html(template)
    return "" if @post.is_deleted? && !@current_user.is_janitor?
    
    if @post.is_flash?
      template.render(:partial => "posts/flash", :locals => {:post => @post})
    elsif @post.is_image?
      template.image_tag(
        @post.file_path_for(@current_user),
        :width => @post.image_width_for(@current_user),
        :height => @post.image_height_for(@current_user),
        "data-original-width" => @post.image_width,
        "data-original-height" => @post.image_height
      )
    end
  end
  
  def note_html
  end
end
