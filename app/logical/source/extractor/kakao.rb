# frozen_string_literal: true

# This handles daumcdn.net and kakaocdn.net image URLs that are used by Tistory, Daum.net, and other Daum/Kakao sites.
# We can't tell which extractor to use based on the URL itself, but if the referer URL is present we can use it to
# delegate to the real extractor.
class Source::Extractor::Kakao < Source::Extractor
  delegate :page_url, :profile_url, :artist_name, :display_name, :username, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

  def allow_referer?
    # Ex: https://panchokworkshop.com/520, https://panchok.tistory.com/520, https://post.naver.com/viewer/postView.naver?volumeNo=28956950&memberNo=23461945
    true
  end

  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      []
    end
  end

  def other_names
    sub_extractor&.other_names || []
  end

  def profile_urls
    sub_extractor&.profile_urls || []
  end

  def tags
    sub_extractor&.tags || []
  end

  def artists
    sub_extractor&.artists || []
  end

  memoize def sub_extractor
    parsed_referer&.extractor(parent_extractor: self)
  end
end
