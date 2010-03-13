class PostSetPresenter < Presenter
  attr_accessor :post_set
  
  def initialize(post_set)
    @post_set = post_set
  end
  
  def posts
    post_set.posts
  end
  
  def tag_list_html
    ""
  end
  
  def wiki_html
    ""
  end
  
  def pagination_html
  end
  
  def post_previews_html
    html = ""
    
    posts.each do |post|
      flags = []
      flags << "pending" if post.is_pending?
      flags << "flagged" if post.is_flagged?
      flags << "deleted" if post.is_deleted?
      
      html << %{<article id="post_#{post.id}" data-id="#{post.id}" data-tags="#{h(post.tag_string)}" data-uploader="#{h(post.uploader_name)}" data-rating="#{post.rating}" data-width="#{post.image_width}" data-height="#{post.image_height}" data-flags="#{flags.join(' ')}">}
      html << %{<a href="/posts/#{post.id}">}
      html << %{<img src="#{post.preview_file_url}">}
      html << %{</a>}
      html << %{</article>}
    end
    
    html.html_safe
  end
end
