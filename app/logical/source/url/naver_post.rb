# frozen_string_literal: true

# @see Source::Extractor::NaverPost
# @see https://post.naver.com
class Source::URL::NaverPost < Source::URL
  RESERVED_USERNAMES = %w[author contents my viewer]

  attr_reader :username, :user_id, :post_id, :full_image_url

  def self.match?(url)
    url.host.in?(%w[post.naver.com m.post.naver.com post-phinf.pstatic.net post.phinf.naver.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://post-phinf.pstatic.net/MjAyMDAyMTVfMjQy/MDAxNTgxNzE2NTY5Njg0.ozzkHtgYHjePRKofX6NbJ_f4gA_4xha9OuLFELr9iAIg.Dm3x5uVIUY0DMlL2vf2JvT3hIucI8gE2lKnTIXcf3Awg.JPEG/%EB%8F%8C1.jpg?type=w1200 (sample)
    # https://post-phinf.pstatic.net/MjAyMDAyMTVfMjQy/MDAxNTgxNzE2NTY5Njg0.ozzkHtgYHjePRKofX6NbJ_f4gA_4xha9OuLFELr9iAIg.Dm3x5uVIUY0DMlL2vf2JvT3hIucI8gE2lKnTIXcf3Awg.JPEG/%EB%8F%8C1.jpg (full)
    # https://post.phinf.naver.net/MjAyMDAyMTVfMjQy/MDAxNTgxNzE2NTY5Njg0.ozzkHtgYHjePRKofX6NbJ_f4gA_4xha9OuLFELr9iAIg.Dm3x5uVIUY0DMlL2vf2JvT3hIucI8gE2lKnTIXcf3Awg.JPEG/%EB%8F%8C1.jpg (full)
    #
    # http://post-phinf.pstatic.net/20160324_74/1458783545129zPGJg_JPEG/%B0%AD%B3%B2TV_%B0%C9%B1%D7%B7%EC_%BD%BA%C0%A7%C4%A1%BA%A3%B8%AE_%B0%A1%BB%F3%C7%F6%BD%C7_360VR_%BC%EE%C4%C9%C0%CC%BD%BA_%B9%C2%C1%F7%BA%F1%B5%F0%BF%C0_%BB%E7%C1%F82.jpg/IT8SeAh7YSaM55bq7KMOEE5ImDlU.jpg
    # http://post.phinf.naver.net/20160324_74/1458783545129zPGJg_JPEG/%B0%AD%B3%B2TV_%B0%C9%B1%D7%B7%EC_%BD%BA%C0%A7%C4%A1%BA%A3%B8%AE_%B0%A1%BB%F3%C7%F6%BD%C7_360VR_%BC%EE%C4%C9%C0%CC%BD%BA_%B9%C2%C1%F7%BA%F1%B5%F0%BF%C0_%BB%E7%C1%F82.jpg/IT8SeAh7YSaM55bq7KMOEE5ImDlU.jpg
    in /phinf$/, ("naver.net" | "pstatic.net"), *rest
      @full_image_url = without(:query).to_normalized_s

    # https://post.naver.com/viewer/image.nhn?src=https://post-phinf.pstatic.net/MjAxODEyMjZfMiAg/MDAxNTQ1NzgzMzAwMDkz.uFFOHZ8HeFnn-9_qpr3kl4QAt4pvMBi1O1evmSIp8Y4g.PMJ-2dLbfuqMxzEg62Bc84vUn7v0Cjttfaxd8HaY9TIg.JPEG/%25EA%25B0%259C%25EC%259D%25B8%25EC%259E%2591_%25EB%25B8%2594%25EC%2586%258C%25EB%25A6%25B0%25EC%25A1%25B1.jpg
    in _, "naver.com", "viewer", ("image.nhn" | "image.naver") if params[:src].present?
      @full_image_url = Source::URL.parse(params[:src]).try(:full_image_url)

    # https://m.post.naver.com/viewer/postView.naver?volumeNo=33304944&memberNo=7662880
    # https://post.naver.com/viewer/postView.nhn?volumeNo=33304944&memberNo=7662880
    # https://m.post.naver.com/author/board.naver?memberNo=7662880
    # https://post.naver.com/my.nhn?memberNo=6072169
    # https://post.naver.com/my/followingList.naver?memberNo=6072169&navigationType=push
    # https://post.naver.com/my/like/list.naver?memberNo=6072169&navigationType=push
    # https://post.naver.com/myProfile.naver?memberNo=1454011
    # https://post.naver.com/series.naver?memberNo=1454011
    in _, "naver.com", *rest if params[:memberNo].present?
      @user_id = params[:memberNo]
      @post_id = params[:volumeNo]

    # https://post.naver.com/my/followerList.naver?followNo=6072169&navigationType=push
    in _, "naver.com", *rest if params[:followNo].present?
      @user_id = params[:followNo]

    # https://post.naver.com/dltkdrlf92
    # https://m.post.naver.com/dltkdrlf92
    in _, "naver.com", username, *rest unless username.in?(RESERVED_USERNAMES) || username.match?(/\.(nhn|naver)$/)
      @username = username

    # https://blog.kakaocdn.net/dn/cJSXhs/btqHBRGLYvT/uJXMz48vCSKHMWs4aN8ytK/img.jpg
    else
      nil
    end
  end

  def mobile_page_url
    "https://m.post.naver.com/viewer/postView.naver?volumeNo=#{post_id}&memberNo=#{user_id}" if post_id.present? && user_id.present?
  end

  def page_url
    "https://post.naver.com/viewer/postView.naver?volumeNo=#{post_id}&memberNo=#{user_id}" if post_id.present? && user_id.present?
  end

  def profile_url
    if user_id.present?
      "https://post.naver.com/my.naver?memberNo=#{user_id}"
    elsif username.present?
      "https://post.naver.com/#{username}"
    end
  end
end
