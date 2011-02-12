class PostPresenter < Presenter
  def self.preview(post)
    flags = []
    flags << "pending" if post.is_pending?
    flags << "flagged" if post.is_flagged?
    flags << "deleted" if post.is_deleted?
    
    html =  %{<article id="post_#{post.id}" data-id="#{post.id}" data-tags="#{h(post.tag_string)}" data-uploader="#{h(post.uploader_name)}" data-rating="#{post.rating}" data-width="#{post.image_width}" data-height="#{post.image_height}" data-flags="#{flags.join(' ')}">}
    html << %{<a href="/posts/#{post.id}">}
    html << %{<img src="#{post.preview_file_url}">}
    html << %{</a>}
    html << %{</article>}
    html.html_safe
  end
  
  def initialize(post)
    @post = post
  end
  
  def preview_html
    PostPresenter.preview(@post)
  end

  def image_html(template)
    return template.content_tag("p", "This image was deleted.") if @post.is_deleted? && !CurrentUser.user.is_janitor?
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
