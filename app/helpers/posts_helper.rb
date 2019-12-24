module PostsHelper
  def post_search_counts_enabled?
    Danbooru.config.enable_post_search_counts && Danbooru.config.reportbooru_server.present? && Danbooru.config.reportbooru_key.present?
  end

  def discover_mode?
    params[:tags] =~ /order:rank/ || params[:action] =~ /searches|viewed/
  end

  def next_page_url
    current_page = (params[:page] || 1).to_i
    url_for(nav_params_for(current_page + 1)).html_safe
  end

  def prev_page_url
    current_page = (params[:page] || 1).to_i
    if current_page >= 2
      url_for(nav_params_for(current_page - 1)).html_safe
    else
      nil
    end
  end

  def missed_post_search_count_js
    return nil unless post_search_counts_enabled?

    if params[:ms] == "1" && @post_set.post_count == 0 && @post_set.is_single_tag?
      session_id = session.id
      verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.reportbooru_key, serializer: JSON, digest: "SHA256")
      sig = verifier.generate("#{params[:tags]},#{session_id}")
      return render("posts/partials/index/missed_search_count", sig: sig)
    end
  end

  def post_search_count_js
    return nil unless post_search_counts_enabled?

    if params[:action] == "index" && params[:page].nil?
      tags = Tag.scan_query(params[:tags]).sort.join(" ")

      if tags.present?
        key = "ps-#{tags}"
        value = session.id
        verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.reportbooru_key, serializer: JSON, digest: "SHA256")
        sig = verifier.generate("#{key},#{value}")
        return render("posts/partials/index/search_count", sig: sig)
      end
    end

    return nil
  end

  def post_view_count_js
    return nil
    return nil unless post_search_counts_enabled?

    msg = "#{params[:id]},#{session.id}"
    msg = ActiveSupport::MessageVerifier.new(Danbooru.config.reportbooru_key, serializer: JSON, digest: "SHA256").generate(msg)
    return render("posts/partials/show/view_count", msg: msg)
  end

  def post_source_tag(post)
    # Only allow http:// and https:// links. Disallow javascript: links.
    if post.source =~ %r!\Ahttps?://!i
      external_link_to(post.normalized_source, strip: :subdomain) + "&nbsp;".html_safe + link_to("»", post.source, rel: "external noreferrer nofollow")
    else
      post.source
    end
  end

  def post_favlist(post)
    post.favorited_users.reverse_each.map {|user| link_to_user(user)}.join(", ").html_safe
  end

  def has_parent_message(post, parent_post_set)
    html = ""

    html << "This post belongs to a "
    html << link_to("parent", posts_path(:tags => "parent:#{post.parent_id}"))
    html << " (deleted)" if parent_post_set.parent.first.is_deleted?

    sibling_count = parent_post_set.children.count - 1
    if sibling_count > 0
      html << " and has "
      text = (sibling_count == 1) ? "a sibling" : "#{sibling_count} siblings"
      html << link_to(text, posts_path(:tags => "parent:#{post.parent_id}"))
    end

    html << " (#{link_to_wiki "learn more", "help:post_relationships"}) "

    html << link_to("&laquo; hide".html_safe, "#", :id => "has-parent-relationship-preview-link")

    html.html_safe
  end

  def has_children_message(post, children_post_set)
    html = ""

    html << "This post has "
    text = (children_post_set.children.count == 1) ? "a child" : "#{children_post_set.children.count} children"
    html << link_to(text, posts_path(:tags => "parent:#{post.id}"))

    html << " (#{link_to_wiki "learn more", "help:post_relationships"}) "

    html << link_to("&laquo; hide".html_safe, "#", :id => "has-children-relationship-preview-link")

    html.html_safe
  end

  def pool_link(pool)
    render("posts/partials/show/pool_link", post: @post, pool: pool)
  end

  def is_pool_selected?(pool)
    return false if params.key?(:q)
    return false if params.key?(:favgroup_id)
    return false if !params.key?(:pool_id)
    return params[:pool_id].to_i == pool.id
  end

  def show_tag_change_notice?
    Tag.scan_query(params[:tags]).size == 1 && TagChangeNoticeService.get_forum_topic_id(params[:tags])
  end

  private

  def nav_params_for(page)
    query_params = params.except(:controller, :action, :id).merge(page: page).permit!
    { params: query_params }
  end
end
