class PostPresenter < Presenter
  def initialize(post)
    @post = post
  end

  def image_html(template)
    return template.content_tag("p", "This image was deleted.") if @post.is_removed? && !CurrentUser.user.is_janitor?
    return template.content_tag("p", "You need a privileged account to see this image.") if !Danbooru.config.can_see_post?(@post, CurrentUser.user)
    
    if @post.is_flash?
      template.render(:partial => "posts/partials/show/flash", :locals => {:post => @post})
    elsif @post.is_image?
      template.render(:partial => "posts/partials/show/image", :locals => {:post => @post})
    end
  end
  
  def tag_list_html(template)
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
    @tag_set_presenter.tag_list_html(template, :show_extra_links => CurrentUser.user.is_privileged?)
  end
end
