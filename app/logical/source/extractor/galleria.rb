# frozen_string_literal: true

# @see Source::URL::Galleria
class Source::Extractor::Galleria < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      page&.css(".TimeLineIllustImageFile").to_a.pluck("src").map do |url|
        # //galleria-img.emotionflow.com/user_img9/75596/i1661081253247_941.jpeg -> https://galleria-img.emotionflow.com/user_img9/75596/i1661081253247_941.jpeg
        URI.join("https://", url).to_s
      end
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def artist_name
    page&.at(".TimeLineUserName > span")&.text
  end

  def artist_commentary_title
    page&.at(".TimeLineIllustTitle")&.text
  end

  def artist_commentary_desc
    page&.at(".TimeLineIllustDesc")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://galleria.emotionflow.com") do |element|
      case element.name
      in "h2"
        element.name = "div"

      in "a" if element["class"]&.in?(%w[AutoLinkTag AutoLinkMyTag])
        element.content = nil

      else
        nil
      end
    end
  end

  def tags
    page&.css(".TimeLineIllustDesc .AutoLinkTag, .TimeLineIllustDesc .AutoLinkMyTag").to_a.map(&:text).map do |tag|
      if tag.starts_with?("##")
        tag = tag.delete_prefix("##")
        [tag, "https://galleria.emotionflow.com/#{user_id}/#{Danbooru::URL.escape(tag)}"]
      else
        tag = tag.delete_prefix("#")
        [tag, "https://galleria.emotionflow.com/SearchIllustByTagV.jsp?KWD=#{Danbooru::URL.escape(tag)}"]
      end
    end
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id
  end

  memoize def page
    http.cookies(SFL: 3).cache(1.minute).parsed_get(page_url) if page_url.present?
  end
end
