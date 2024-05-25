# frozen_string_literal: true

# @see Source::URL::Miyoushe
class Source::Extractor::Miyoushe < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif article[:vod_list].present?
      article[:vod_list].to_a.map do |video|
        video[:resolutions]&.max_by { _1[:bitrate].to_i }&.dig(:url)
      end
    else
      article[:image_list].to_a.pluck(:url)
    end
  end

  def profile_url
    "#{base_url}/accountCenter/postList?id=#{user_id}" if user_id.present?
  end

  def display_name
    article.dig(:user, :nickname)
  end

  def tags
    article[:topics].to_a.map do |topic|
      [topic[:name], "#{base_url}/topicDetail/#{topic[:id]}"]
    end
  end

  def artist_commentary_title
    article.dig(:post, :subject)&.normalize_whitespace
  end

  def artist_commentary_desc
    article.dig(:post, :structured_content) || article.dig(:post, :content)
  end

  def dtext_artist_commentary_desc
    if article.dig(:post, :structured_content).present?
      DText.from_html(html_artist_commentary_desc, base_url: base_url)
    else
      content = article.dig(:post, :content)&.parse_json&.dig(:describe)
      DText.from_plaintext(content)
    end
  end

  def html_artist_commentary_desc
    artist_commentary_desc&.parse_json.to_a.map do |content|
      content = content.deep_symbolize_keys
      case content[:insert]
      in "\n"
        "<br><br>"
      in String => text if content.dig(:attributes, :link)
        %{<a href="#{CGI.escapeHTML(content.dig(:attributes, :link))}">#{CGI.escapeHTML(text)}</a>}
      in String => text
        text = CGI.escapeHTML(text)

        # For video posts, newlines count as a single line break. For image posts, newlines start a new paragraph.
        br = article[:vod_list].present? ? "<br>" : "<br><br>"
        text = text.gsub("\n", br)
        text = "<b>#{text}</b>" if content.dig(:attributes, :bold)

        "<span>#{text}</span>"
      in { divider: }
        "<hr>"
      in { image: }
        %{<p><img src="#{CGI.escapeHTML(image)}" alt="[image]"></p>}
      in { vod: }
        "" # Ignore videos
      else
        ""
      end
    end.join
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || article.dig(:user, :uid)
  end

  def article_id
    parsed_url.article_id || parsed_referer&.article_id
  end

  def base_url
    if site_name == "Hoyolab"
      "https://www.hoyolab.com"
    else
      # We normalize the subsite to /sr/ because it doesn't actually matter and so that artist URLs are consistent for artist finding purposes.
      "https://www.miyoushe.com/sr"
    end
  end

  memoize def article
    api_response.dig(:data, :post) || {}
  end

  memoize def api_response
    if site_name == "Hoyolab"
      api_url = "https://bbs-api-os.hoyolab.com/community/post/wapi/getPostFull?post_id=#{article_id}" if article_id.present?
      http.cache(1.minute).parsed_get(api_url) || {}
    else
      api_url = "https://bbs-api.miyoushe.com/post/wapi/getPostFull?post_id=#{article_id}" if article_id.present?
      http.headers(Referer: "https://www.miyoushe.com").cache(1.minute).parsed_get(api_url) || {}
    end
  end
end
