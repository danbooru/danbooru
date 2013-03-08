class PostPresenter < Presenter
  def self.preview(post, options = {})
    if post.is_deleted? && !CurrentUser.is_privileged?
      return ""
    end
    
    unless Danbooru.config.can_user_see_post?(CurrentUser.user, post)
      return ""
    end
    
    flags = []
    flags << "pending" if post.is_pending?
    flags << "flagged" if post.is_flagged?
    flags << "deleted" if post.is_deleted?
    
    path = options[:path_prefix] || "/posts"
    
    html =  %{<article class="post-preview" id="post_#{post.id}" data-id="#{post.id}" data-tags="#{h(post.tag_string)}" data-uploader="#{h(post.uploader_name)}" data-rating="#{post.rating}" data-width="#{post.image_width}" data-height="#{post.image_height}" data-flags="#{flags.join(' ')}" data-parent-id="#{post.parent_id}" data-has-children="#{post.has_children?}" data-score="#{post.score}">}
    if options[:tags].present?
      tag_param = "?tags=#{CGI::escape(options[:tags])}"
    elsif options[:pool_id]
      tag_param = "?pool_id=#{options[:pool_id]}"
    else
      tag_param = nil
    end
    html << %{<a href="#{path}/#{post.id}#{tag_param}">}
    html << %{<img src="#{post.preview_file_url}" alt="#{h(post.tag_string)}">}
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
  
  def humanized_tag_string
    @post.tag_string.split(/ /).slice(0, 25).join(", ").tr("_", " ")
  end
  
  def humanized_essential_tag_string
    string = []
    
    if @post.character_tags.any?
      string << @post.character_tags.slice(0, 5).to_sentence
    end
    
    if @post.copyright_tags.any?
      string << "from"
      string << @post.copyright_tags.slice(0, 5).to_sentence
    end
    
    if @post.artist_tags.any?
      string << "drawn by"
      string << @post.artist_tags.to_sentence
    end
    
    string.join(" ").tr("_", " ")
  end
  
  def image_html(template)
    return template.content_tag("p", "This image was deleted.") if @post.is_deleted? && !CurrentUser.user.is_privileged?
    return template.content_tag("p", "You need a privileged account to see this image.") if !Danbooru.config.can_user_see_post?(CurrentUser.user, @post)
    
    if @post.is_flash?
      template.render("posts/partials/show/flash", :post => @post)
    elsif !@post.is_image?
      template.render("posts/partials/show/download", :post => @post)
    elsif @post.is_image?
      template.render("posts/partials/show/image", :post => @post)
    end
  end
  
  def tag_list_html(template, options = {})
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
    @tag_set_presenter.tag_list_html(template, options.merge(:show_extra_links => CurrentUser.user.is_privileged?))
  end
  
  def split_tag_list_html(template, options = {})
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
    @tag_set_presenter.split_tag_list_html(template, options.merge(:show_extra_links => CurrentUser.user.is_privileged?))
  end
  
  def has_nav_links?(template)
    (template.params[:tags].present? && template.params[:tags] !~ /order:/) || @post.pools.active.any?
  end
  
  def post_footer_for_pool_html(template)
    if template.params[:pool_id]
      pool = Pool.where(:id => template.params[:pool_id]).first
      return if pool.nil?
      return if pool.neighbors(@post).next.nil?
      template.link_to("Next in #{pool.name}", template.post_path(pool.neighbors(@post).next))
    else
      nil
    end
  end
  
  def pool_html(template)
    html = ["<ul>"]
    
    if template.params[:pool_id].present?
      pool = Pool.where(:id => template.params[:pool_id]).first
      return if pool.nil?
      html = pool_link_html(html, template, pool, :include_rel => true)
      
      @post.pools.active.where("id <> ?", template.params[:pool_id]).each do |other_pool|
        html = pool_link_html(html, template, other_pool)
      end
    else
      first = true
      @post.pools.active.each do |pool|
        if first && template.params[:tags].blank?
          html = pool_link_html(html, template, pool, :include_rel => true)
          first = false
        else
          html = pool_link_html(html, template, pool)
        end
      end
    end
    
    html << "</ul>"
    html.join("\n").html_safe
  end
  
  def pool_link_html(html, template, pool, options = {})
    pool_html = ["<li>"]
    match_found = false
    
    if options[:include_rel]
      prev_rel = "prev"
      next_rel = "next"
      klass = "active"
    else
      prev_rel = nil
      next_rel = nil
      klass = ""
    end
    
    if pool.neighbors(@post).previous
      pool_html << template.link_to("&laquo;prev".html_safe, template.post_path(pool.neighbors(@post).previous, :pool_id => pool.id), :rel => prev_rel, :class => "#{klass} prev")
      match_found = true
    else
      pool_html << '<span class="prev">&laquo;prev</span>'
    end
    
    pool_html << ' <span class="pool-name ' + klass + '">'
    pool_html << template.link_to("Pool: #{pool.pretty_name}", template.pool_path(pool))
    pool_html << '</span> '

    if pool.neighbors(@post).next
      pool_html << template.link_to("next&raquo;".html_safe, template.post_path(pool.neighbors(@post).next, :pool_id => pool.id), :rel => next_rel, :class => "#{klass} next")
      match_found = true
    else
      pool_html << '<span class="next">next&raquo;</span>'
    end
    
    pool_html << "</li>"
    
    if match_found
      html += pool_html
    end

    html
  end
end
