# frozen_string_literal: true

# @see Source::URL::ArtStreet
class Source::Extractor
  class ArtStreet < Source::Extractor
    def image_urls
      if parsed_url.full_image_url.present?
        [parsed_url.full_image_url]
      elsif book_id.present?
        cover_url = book_api_response["coverUrl"]
        image_urls = book_api_response.dig("chapterList", 0, "pageList").to_a.pluck("publicBgImage")

        [cover_url, *image_urls].compact_blank
      else
        page&.css(".pictureDetails__image img").to_a.pluck("src").map do |url|
          Source::URL.parse(url).full_image_url
        end
      end
    end

    def profile_url
      author_url
    end

    def profile_urls
      [author_url, user_url].compact_blank.uniq
    end

    def user_url
      # https://medibang.com/u/16672238/ or https://medibang.com/author/749476/
      url = author_page&.at("a.contentsTab[data-tgt=0]")&.attr("href")
      url if Source::URL.parse(url)&.user_id.present?
    end

    def author_url
      # https://medibang.com/author/8769655 (JS redirects to https://medibang.com/u/16672238/)
      "https://medibang.com/author/#{parsed_url.author_id}/" if parsed_url.author_id.present?
    end

    def display_name
      page&.css(".pictureDetails-authorArea2 .pictureDetails__authorName, .book_info-author-name")&.text&.strip
    end

    def tags
      page&.css(".cmn-tag a.tag[href^='https://'], #js-tag-view-area .keyword a").to_a.map do |tag|
        [tag.text.strip, tag.attr("href")]
      end
    end

    def artist_commentary_title
      page&.css(".pictureDetails__titleLink, .series_title_area h1.name")&.text.to_s.normalize_whitespace.strip.gsub("\r\n", " ").squeeze(" ")
    end

    def artist_commentary_desc
      page&.at(".pictureDetails__summaryOriginal, #originInfo, .summary-txt:not(#truncInfo)")&.inner_html&.strip
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc, base_url: "https://medibang.com")
    end

    def book_id
      parsed_url.book_id
    end

    def book_api_url
      "https://medibang.com/api/book/fixedList2/#{book_id}/?quality=pc" if book_id
    end

    memoize def book_api_response
      http.cache(1.minute).parsed_get(book_api_url) || {}
    end

    memoize def page
      http.cache(1.minute).parsed_get(page_url)
    end

    memoize def author_page
      http.cache(1.minute).parsed_get(author_url)
    end

    def http
      super.cookies(MSID: Danbooru.config.art_street_session_cookie)
    end
  end
end
