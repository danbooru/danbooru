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
    post.id == 1 && post.created_at.strftime("%m-%d") == Time.zone.today.strftime("%m-%d") && !post.created_at.today?
  end

  def image_container_data_attributes(post, current_user)
    attributes = {
      "data-id" => post.id,
      "data-tags" => post.tag_string,
      "data-rating" => post.rating,
      "data-large-width" => post.large_image_width,
      "data-large-height" => post.large_image_height,
      "data-width" => post.image_width,
      "data-height" => post.image_height,
      "data-flags" => post.status_flags,
      "data-score" => post.score,
      "data-uploader-id" => post.uploader_id,
      "data-source" => post.source,
      "data-normalized-source" => post.normalized_source,
      "data-can-have-notes" => post.can_have_notes?,
    }

    if post.visible?(current_user)
      attributes["data-file-url"] = post.file_url
    end

    attributes
  end
end
