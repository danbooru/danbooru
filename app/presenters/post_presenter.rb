class PostPresenter < Presenter
  attr_reader :pool, :next_post_in_pool
  delegate :tag_list_html, :split_tag_list_html, :inline_tag_list_html, to: :tag_set_presenter

  def self.preview(post, options = {})
    if post.nil?
      return "<em>none</em>".html_safe
    end

    if !options[:show_deleted] && post.is_deleted? && options[:tags] !~ /status:(?:all|any|deleted|banned)/ && !options[:raw]
      return ""
    end

    if !post.visible?
      return ""
    end

    if post.is_ugoira? && !post.has_ugoira_webm?
      # ugoira preview gen is async so dont render it immediately
      return ""
    end

    path = options[:path_prefix] || "/posts"
    if Danbooru.config.enable_image_cropping && options[:show_cropped] && post.has_cropped? && !CurrentUser.user.disable_cropped_thumbnails?
      cropped_src = post.crop_file_url
    else
      cropped_src = post.preview_file_url
    end

    html =  %{<article itemscope itemtype="http://schema.org/ImageObject" id="post_#{post.id}" class="#{preview_class(post, options)}" #{data_attributes(post)}>}
    if options[:tags].present? && !CurrentUser.is_anonymous?
      tag_param = "?tags=#{CGI::escape(options[:tags])}"
    elsif options[:pool_id] || options[:pool]
      tag_param = "?pool_id=#{CGI::escape((options[:pool_id] || options[:pool].id).to_s)}"
    elsif options[:favgroup_id] || options[:favgroup]
      tag_param = "?favgroup_id=#{CGI::escape((options[:favgroup_id] || options[:favgroup].id).to_s)}"
    else
      tag_param = nil
    end
    html << %{<a href="#{path}/#{post.id}#{tag_param}">}

    tooltip = "#{post.tag_string} rating:#{post.rating} score:#{post.score}"
    html << %{<picture>}
    html << %{<source media="(max-width: 660px)" srcset="#{cropped_src}">}
    html << %{<source media="(min-width: 660px)" srcset="#{post.preview_file_url}">}
    html << %{<img itemprop="thumbnailUrl" class="has-cropped-#{post.has_cropped?}" src="#{post.preview_file_url}" title="#{h(tooltip)}" alt="#{h(post.tag_string)}">}
    html << %{</picture>}
    html << %{</a>}

    if options[:pool]
      html << %{<p class="desc">}
      html << %{<a href="/pools/#{options[:pool].id}">}
      html << h(options[:pool].pretty_name.truncate(80))
      html << %{</a>}
      html << %{</p>}
    end

    if options[:similarity]
      html << %{<p class="desc">}
      html << "Similarity: #{options[:similarity].round}%"
      html << %{</p>}
    end

    if options[:size]
      html << %{<p class="desc">}
      html << post.file_size.to_s(:human_size)
      html << " (#{post.image_width}x#{post.image_height})"
      html << %{</p>}
    end

    html << %{</article>}
    html.html_safe
  end

  def self.preview_class(post, options = {})
    klass = "post-preview"
    # klass << " large-cropped" if post.has_cropped? && options[:show_cropped]
    klass << " captioned" if options.values_at(:pooled, :size, :similarity).any?(&:present?)
    klass << " post-status-pending" if post.is_pending?
    klass << " post-status-flagged" if post.is_flagged?
    klass << " post-status-deleted" if post.is_deleted?
    klass << " post-status-has-parent" if post.parent_id
    klass << " post-status-has-children" if post.has_visible_children?
    klass
  end

  def self.data_attributes(post)
    attributes = %{
      data-id="#{post.id}"
      data-has-sound="#{post.has_tag?('video_with_sound|flash_with_sound')}"
      data-tags="#{h(post.tag_string)}"
      data-pools="#{post.pool_string}"
      data-approver-id="#{post.approver_id}"
      data-rating="#{post.rating}"
      data-width="#{post.image_width}"
      data-height="#{post.image_height}"
      data-flags="#{post.status_flags}"
      data-parent-id="#{post.parent_id}"
      data-has-children="#{post.has_children?}"
      data-score="#{post.score}"
      data-views="#{post.view_count}"
      data-fav-count="#{post.fav_count}"
      data-pixiv-id="#{post.pixiv_id}"
      data-file-ext="#{post.file_ext}"
      data-source="#{h(post.source)}"
      data-top-tagger="#{post.keeper_id}"
      data-uploader-id="#{post.uploader_id}"
      data-normalized-source="#{h(post.normalized_source)}"
      data-is-favorited="#{post.favorited_by?(CurrentUser.user.id)}"
    }

    if CurrentUser.is_moderator?
      attributes += %{
        data-uploader="#{h(post.uploader_name)}"
      }
    end

    if post.visible?
      attributes += %{
        data-md5="#{post.md5}"
        data-file-url="#{post.file_url}"
        data-large-file-url="#{post.large_file_url}"
        data-preview-file-url="#{post.preview_file_url}"
      }
    end

    attributes.html_safe
  end

  def initialize(post)
    @post = post
  end

  def tag_set_presenter
    @tag_set_presenter ||= TagSetPresenter.new(@post.tag_array)
  end

  def preview_html
    PostPresenter.preview(@post)
  end

  def humanized_tag_string
    @post.tag_string.split(/ /).slice(0, 25).join(", ").tr("_", " ")
  end

  def humanized_essential_tag_string
    @post.humanized_essential_tag_string
  end

  def filename_for_download
    "#{humanized_essential_tag_string} - #{@post.md5}.#{@post.file_ext}"
  end

  def categorized_tag_groups
    string = []

    TagCategory.categorized_list.each do |category|
      if @post.typed_tags(category).any?
        string << @post.typed_tags(category).join(" ")
      end
    end
    
    string
  end

  def categorized_tag_string
    categorized_tag_groups.join(" \n")
  end

  def safe_mode_message(template)
    html = ["This image is unavailable on safe mode (#{Danbooru.config.app_name}). Go to "]
    html << template.link_to("Danbooru", "https://danbooru.donmai.us") # XXX don't hardcode.
    html << " or disable safe mode to view ("
    html << template.link_to("learn more", template.wiki_pages_path(title: "help:user_settings"))
    html << ")."
    html.join.html_safe
  end

  def image_html(template)
    return template.content_tag("p", "The artist requested removal of this image") if @post.banblocked?
    return template.content_tag("p", template.link_to("You need a gold account to see this image.", template.new_user_upgrade_path)) if @post.levelblocked?
    return template.content_tag("p", safe_mode_message(template)) if @post.safeblocked?

    if @post.is_flash?
      template.render("posts/partials/show/flash", :post => @post)
    elsif @post.is_video?
      template.render("posts/partials/show/video", :post => @post)
    elsif @post.is_ugoira?
      template.render("posts/partials/show/ugoira", :post => @post)      
    elsif !@post.is_image?
      template.render("posts/partials/show/download", :post => @post)
    elsif @post.is_image?
      template.render("posts/partials/show/image", :post => @post)
    end
  end

  def has_nav_links?(template)
    has_sequential_navigation?(template.params) || @post.pools.undeleted.any? || @post.favorite_groups(active_id=template.params[:favgroup_id]).any?
  end

  def has_sequential_navigation?(params)
    return false if Tag.has_metatag?(params[:tags], :order, :ordfav, :ordpool)
    return false if params[:pool_id].present? || params[:favgroup_id].present?
    return CurrentUser.user.enable_sequential_post_navigation 
  end

  def post_footer_for_pool_html(template)
    if template.params[:pool_id]
      pool = Pool.where(:id => template.params[:pool_id]).first
      return if pool.nil?
      return if pool.neighbors(@post).next.nil?
      template.link_to("Next in #{pool.pretty_name}", template.post_path(pool.neighbors(@post).next))
    else
      nil
    end
  end

  def pool_html(template)
    html = ["<ul>"]

    if template.params[:pool_id].present? && @post.belongs_to_pool_with_id?(template.params[:pool_id])
      pool = Pool.where(:id => template.params[:pool_id]).first
      return if pool.nil?
      html += pool_link_html(template, pool, :include_rel => true)

      other_pools = @post.pools.undeleted.where("id <> ?", template.params[:pool_id]).series_first
      other_pools.each do |other_pool|
        html += pool_link_html(template, other_pool)
      end
    else
      first = true
      pools = @post.pools.undeleted
      pools.each do |pool|
        if first && template.params[:tags].blank? && template.params[:favgroup_id].blank?
          html += pool_link_html(template, pool, :include_rel => true)
          first = false
        else
          html += pool_link_html(template, pool)
        end
      end
    end

    html << "</ul>"
    html.join("\n").html_safe
  end

  def pool_link_html(template, pool, options = {})
    pool_html = [%{<li id="nav-link-for-pool-#{pool.id}" class="pool-category-#{pool.category}">}]
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

    if @post.id != pool.post_id_array.first
      pool_html << template.link_to("&laquo;".html_safe, template.post_path(pool.post_id_array.first, :pool_id => pool.id), :class => "#{klass} first", :title => "to page 1")
    else
      pool_html << '<span class="first">&laquo;</span>'
    end

    if pool.neighbors(@post).previous
      pool_html << template.link_to("&lsaquo;&thinsp;prev".html_safe, template.post_path(pool.neighbors(@post).previous, :pool_id => pool.id), :rel => prev_rel, :class => "#{klass} prev", :title => "to page #{pool.page_number(pool.neighbors(@post).previous)}")
      match_found = true
    else
      pool_html << '<span class="prev">&lsaquo;&thinsp;prev</span>'
    end

    pool_html << ' <span class="pool-name ' + klass + '">'
    pool_html << template.link_to("Pool: #{pool.pretty_name}", template.pool_path(pool), :title => "page #{pool.page_number(@post.id)}/#{pool.post_count}")
    pool_html << '</span> '

    if pool.neighbors(@post).next
      @next_post_in_pool = pool.neighbors(@post).next
      pool_html << template.link_to("next&thinsp;&rsaquo;".html_safe, template.post_path(@next_post_in_pool, :pool_id => pool.id), :rel => next_rel, :class => "#{klass} next", :title => "to page #{pool.page_number(@next_post_in_pool)}")
      match_found = true
    else
      pool_html << '<span class="next">next&thinsp;&rsaquo;</span>'
    end

    if @post.id != pool.post_id_array.last
      pool_html << template.link_to("&raquo;".html_safe, template.post_path(pool.post_id_array.last, :pool_id => pool.id), :class => "#{klass} last", :title => "to page #{pool.post_count}")
    else
      pool_html << '<span class="last">&raquo;</span>'
    end

    pool_html << "</li>"
    pool_html
  end
end
