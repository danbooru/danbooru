# frozen_string_literal: true

module PostsHelper
  def reportbooru_enabled?
    Danbooru.config.reportbooru_server.present? && Danbooru.config.reportbooru_key.present?
  end

  def discover_mode?
    params[:tags] =~ /order:rank/ || params[:action] =~ /searches|viewed/
  end

  def missed_post_search_count_js(tags)
    sig = generate_reportbooru_signature(tags)
    render "posts/partials/index/missed_search_count", sig: sig
  end

  def post_search_count_js(tags)
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
    if source =~ %r{\Ahttps?://}i
      external_link_to(normalized_source, strip: :subdomain) + "&nbsp;".html_safe + link_to("»", source, rel: "external noreferrer nofollow")
    else
      source
    end
  end

  def is_danbirthday?(post)
    post.id == 1 && post.created_at.strftime("%m-%d") == Time.zone.today.strftime("%m-%d")
  end
end
