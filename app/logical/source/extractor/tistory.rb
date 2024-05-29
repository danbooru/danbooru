# frozen_string_literal: true

# @see Source::URL::Tistory
class Source::Extractor::Tistory < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      page&.css("#mainContent .blogview_content img").to_a.pluck(:src).filter_map do |image_url|
        image_url = Source::URL.parse(image_url)

        # Ignore images embedded from other sites (Ex: https://stella-krysmas.tistory.com/6 embeds a broken Twitter image)
        next unless image_url.domain.in?(%w[tistory.com daumcdn.net kakaocdn.net])

        image_url.try(:full_image_url) || image_url.to_s
      end
    end
  end

  def page_url
    # https://caswac1.tistory.com/entry/용사의-선택지가-이상하다 -> https://caswac1.tistory.com/385
    page&.at('meta[property="dg:plink"]')&.attr(:content) || parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def display_name
    page&.at("cite.by_blog")&.text
  end

  def username
    parsed_url.username || parsed_referer&.username
  end

  def tags
    return [] unless profile_url.present?

    page&.css('.list_tag a[rel="tag"]').to_a.map do |tag|
      [tag.text, "#{profile_url}/tag/#{Danbooru::URL.escape(tag.text)}"]
    end
  end

  def artist_commentary_title
    page&.at("h3.tit_blogview")&.text
  end

  def artist_commentary_desc
    page&.css("#mainContent .blogview_content")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: profile_url) do |element|
      case element.name
      in "img"
        element[:alt] = "[image]"
        element[:src] = Source::URL.parse(element[:src]).try(:full_image_url) || element[:src]

      in "figcaption"
        element.name = "p"

      # Replace Youtube embeds.
      in "iframe"
        url = element[:src]
        element.name = "p"
        element.inner_html = %{<a href="#{url}">#{url}</a>}

      # Ignore "See more" button (Ex: https://stella-krysmas.tistory.com/3)
      in "button"
        element.content = nil

      else
        nil
      end
    end
  end

  def mobile_page_url
    parsed_url.mobile_page_url || parsed_referer&.mobile_page_url
  end

  memoize def page
    http.cache(1.minute).parsed_get(mobile_page_url)
  end

  memoize def page_json
    page&.at('script[text()*="window.T.config"]')&.text&.slice(/window.T.config = ({.*?});/, 1)&.parse_json
  end
end
