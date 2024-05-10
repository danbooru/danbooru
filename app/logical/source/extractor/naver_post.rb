# frozen_string_literal: true

# @see Source::URL::NaverPost
class Source::Extractor::NaverPost < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      html&.css('.sect_dsc a[data-linktype="img"]').to_a.map do |link|
        link["data-linkdata"]&.parse_json&.dig("src")
      end
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def artist_name
    page&.at('meta[property="og:author"]')&.attr("content")
  end

  def tags
    page&.css(".__search_tag").to_a.pluck("data-tagname").map do |tag|
      [tag, "https://post.naver.com/tag/overView.naver?tag=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    page&.at('meta[property="og:title"]')&.attr("content")
  end

  def artist_commentary_desc
    html&.at(".sect_dsc")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: profile_url) do |element|
      case element.name

      # Fix image links. Example: https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945
      in "a" if element.at("img").present?
        url = element.at("img").attr("data-src")
        url = Source::URL.parse(url).try(:full_image_url) || url

        element.name = "p"
        element.inner_html = %{<a href="#{url}">[image]</a>}

      # Replace embedded cards with bare links. Example: https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945
      in "div" if element.classes.include?("se_oglink")
        url = element.at("a.__se_link")&.attr("href")
        element.name = "p"
        element.inner_html = %{<a href="#{url}">#{url}</a>}

      # Replace Youtube embeds.
      in "iframe"
        url = element["src"]
        element.name = "p"
        element.inner_html = %{<a href="#{url}">#{url}</a>}

      # Fix captions beneath Youtube embeds.
      in "div" if element.classes.include?("se_mediaCaption")
        element.name = "p"

      else
        nil
      end
    end
  end

  def mobile_page_url
    parsed_url.mobile_page_url || parsed_referer&.mobile_page_url
  end

  memoize def html
    page&.at("script#__clipContent")&.content&.parse_html
  end

  memoize def page
    http.cache(1.minute).parsed_get(mobile_page_url) if mobile_page_url.present?
  end
end
