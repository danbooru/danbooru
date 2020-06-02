module PostsHelper
  def post_previews_html(posts, **options)
    posts.map do |post|
      PostPresenter.preview(post, **options)
    end.join("").html_safe
  end

  def reportbooru_enabled?
    Danbooru.config.reportbooru_server.present? && Danbooru.config.reportbooru_key.present?
  end

  def discover_mode?
    params[:tags] =~ /order:rank/ || params[:action] =~ /searches|viewed/
  end

  def missed_post_search_count_js(tags)
    return unless reportbooru_enabled?

    sig = generate_reportbooru_signature(tags)
    render "posts/partials/index/missed_search_count", sig: sig
  end

  def post_search_count_js(tags)
    return unless reportbooru_enabled?

    sig = generate_reportbooru_signature("ps-#{tags}")
    render "posts/partials/index/search_count", sig: sig
  end

  def post_view_count_js
    return unless reportbooru_enabled?

    msg = generate_reportbooru_signature(params[:id])
    render "posts/partials/show/view_count", msg: msg
  end

  def generate_reportbooru_signature(value)
    verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.reportbooru_key, serializer: JSON, digest: "SHA256")
    verifier.generate("#{value},#{session[:session_id]}")
  end

  def post_source_tag(source, normalized_source = source)
    # Only allow http:// and https:// links. Disallow javascript: links.
    if source =~ %r!\Ahttps?://!i
      external_link_to(normalized_source, strip: :subdomain) + "&nbsp;".html_safe + link_to("»", source, rel: "external noreferrer nofollow")
    else
      source
    end
  end

  def post_favlist(post)
    post.favorited_users.reverse_each.map {|user| link_to_user(user)}.join(", ").html_safe
  end

  def is_pool_selected?(pool)
    return false if params.key?(:q)
    return false if params.key?(:favgroup_id)
    return false if !params.key?(:pool_id)
    return params[:pool_id].to_i == pool.id
  end

  private

  def nav_params_for(page)
    query_params = params.except(:controller, :action, :id).merge(page: page).permit!
    { params: query_params }
  end
end
