class PostPresenter < Presenter
  attr_reader :pool, :next_post_in_pool

  def self.preview(post, options = {})
    if post.nil?
      return "Expunged"
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

    html =  %{<article itemscope itemtype="http://schema.org/ImageObject" id="post_#{post.id}" class="#{preview_class(post, options[:pool])}" #{data_attributes(post)}>}
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
    html << %{<img itemprop="thumbnailUrl" src="#{post.preview_file_url}" alt="#{h(post.tag_string)}">}
    html << %{</a>}

    if options[:pool]
      html << %{<p class="desc">}
      html << %{<a href="/pools/#{options[:pool].id}">}
      html << h(options[:pool].pretty_name.truncate(80))
      html << %{</a>}
      html << %{</p>}
    end

    if options[:size]
      html << %{<p class="desc">}
      html << post.file_size.to_formatted_s(:human_size)
      html << " (#{post.image_width}x#{post.image_height})"
      html << %{</p>}
    end

    html << %{</article>}
    html.html_safe
  end

  def self.preview_class(post, description = nil)
    klass = "post-preview"
    klass << " pooled" if description
    klass << " post-status-pending" if post.is_pending?
    klass << " post-status-flagged" if post.is_flagged?
    klass << " post-status-deleted" if post.is_deleted?
    klass << " post-status-has-parent" if post.parent_id
    klass << " post-status-has-children" if post.has_visible_children?
    klass
  end

  def self.data_attributes(post)
    %{
      data-id="#{post.id}"
      data-has-sound="#{post.has_tag?('video_with_sound|flash_with_sound')}"
      data-tags="#{h(post.tag_string)}"
      data-pools="#{post.pool_string}"
      data-uploader="#{h(post.uploader_name)}"
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
      data-md5="#{post.md5}"
      data-file-ext="#{post.file_ext}"
      data-file-url="#{post.file_url}"
      data-large-file-url="#{post.large_file_url}"
      data-preview-file-url="#{post.preview_file_url}"
      data-source="#{h(post.source)}"
      data-normalized-source="#{h(post.normalized_source)}"
    }.html_safe
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

  def categorized_tag_string
    string = []

    if @post.copyright_tags.any?
      string << @post.copyright_tags.join(" ")
    end

    if @post.character_tags.any?
      string << @post.character_tags.join(" ")
    end

    if @post.artist_tags.any?
      string << @post.artist_tags.join(" ")
    end

    if @post.general_tags.any?
      string << @post.general_tags.join(" ")
    end

    string.join(" \n")
  end

  def humanized_categorized_tag_string
    string = []

    if @post.copyright_tags.any?
      string << @post.copyright_tags
    end

    if @post.character_tags.any?
      string << @post.character_tags
    end

    if @post.artist_tags.any?
      string << @post.artist_tags
    end

    if @post.general_tags.any?
      string << @post.general_tags
    end

    string.flatten.slice(0, 25).join(", ").tr("_", " ")
  end

  def image_html(template)
    return template.content_tag("p", "The artist requested removal of this image") if @post.is_banned? && !CurrentUser.user.is_gold?
    return template.content_tag("p", template.link_to("You need a gold account to see this image.", template.new_user_upgrade_path)) if !Danbooru.config.can_user_see_post?(CurrentUser.user, @post)
    return template.content_tag("p", "This image is unavailable") if !@post.visible?

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

  def tag_list_html(template, options = {})
    tag_set_presenter.tag_list_html(template, options.merge(:show_extra_links => CurrentUser.user.is_gold?))
  end

  def split_tag_list_html(template, options = {})
    tag_set_presenter.split_tag_list_html(template, options.merge(:show_extra_links => CurrentUser.user.is_gold?))
  end

  def inline_tag_list_html(template)
    tag_set_presenter.inline_tag_list(template)
  end

  def has_nav_links?(template)
    (CurrentUser.user.enable_sequential_post_navigation && template.params[:tags].present? && template.params[:tags] !~ /(?:^|\s)(?:order|ordfav|ordpool):/) || @post.pools.any? || @post.favorite_groups(active_id=template.params[:favgroup_id]).any?
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

      other_pools = @post.pools.where("id <> ?", template.params[:pool_id]).series_first
      other_pools.each do |other_pool|
        html += pool_link_html(template, other_pool)
      end
    else
      first = true
      pools = @post.pools.series_first
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

  def comment_replacement_message(replacer = CurrentUser.user)
    "@#{replacer.name} replaced this post with a new image:\n\n#{replacement_message}"
  end

  def modaction_replacement_message
    "replaced post ##{@post.id}:\n\n#{replacement_message}"
  end

  def replacement_message
    linked_source = linked_source(@post.source)
    linked_source_was = linked_source(@post.source_was)

    <<-EOS.strip_heredoc
      [table]
        [tbody]
          [tr]
            [th]Old[/th]
            [td]#{linked_source_was}[/td]
            [td]#{@post.md5_was}[/td]
            [td]#{@post.file_ext_was}[/td]
            [td]#{@post.image_width_was} x #{@post.image_height_was}[/td]
            [td]#{@post.file_size_was.to_s(:human_size, precision: 4)}[/td]
          [/tr]
          [tr]
            [th]New[/th]
            [td]#{linked_source}[/td]
            [td]#{@post.md5}[/td]
            [td]#{@post.file_ext}[/td]
            [td]#{@post.image_width} x #{@post.image_height}[/td]
            [td]#{@post.file_size.to_s(:human_size, precision: 4)}[/td]
          [/tr]
        [/tbody]
      [/table]
    EOS
  end

protected

  def linked_source(source)
    # truncate long sources in the middle: "www.pixiv.net...lust_id=23264933"
    truncated_source = source.gsub(%r{\Ahttps?://}, "").truncate(64, omission: "...#{source.last(32)}")

    if source =~ %r{\Ahttps?://}i
      %("#{truncated_source}":[#{source}])
    else
      truncated_source
    end
  end
end
