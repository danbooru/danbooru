# frozen_string_literal: true

# @see https://comic.naver.com/community
class Source::URL::NaverComic < Source::URL
  site "Naver Comic", url: "https://comic.naver.com", domains: %w[naver.com]

  attr_reader :user_id, :post_id, :title_id, :chapter_no

  def self.match?(url)
    url.host.in?(%w[comic.naver.com m.comic.naver.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3
    # https://m.comic.naver.com/community/u/_q40ec1/posts/0-q40ec1-3
    in _, "naver.com", "community", "u", user_id, "posts", post_id
      @user_id = user_id
      @post_id = post_id

    # https://comic.naver.com/community/u/_q40ec1
    # https://comic.naver.com/community/u/_rbv5l
    in _, "naver.com", "community", "u", user_id
      @user_id = user_id

    # https://comic.naver.com/webtoon/detail?titleId=183559&no=1
    # https://comic.naver.com/challenge/detail?titleId=846023&no=8
    # https://comic.naver.com/bestChallenge/detail.nhn?titleId=717924&no=1
    in _, "naver.com", *rest if params[:titleId].present? && params[:no].present?
      @title_id = params[:titleId]
      @chapter_no = params[:no]

    # https://comic.naver.com/bestChallenge/list.nhn?titleId=717924
    # https://comic.naver.com/challenge/list?titleId=846023
    # https://comic.naver.com/webtoon/list?titleId=817631
    # https://m.comic.naver.com/webtoon/list?titleId=817631
    in _, "naver.com", *rest if params[:titleId].present?
      @title_id = params[:titleId]

    else
      nil
    end
  end

  def page_url
    if user_id.present? && post_id.present?
      "https://comic.naver.com/community/u/#{user_id}/posts/#{post_id}"
    elsif title_id.present? && chapter_no.present?
      "https://comic.naver.com/webtoon/detail?titleId=#{title_id}&no=#{chapter_no}"
    elsif title_id.present?
      "https://comic.naver.com/webtoon/list?titleId=#{title_id}"
    end
  end

  def profile_url
    "https://comic.naver.com/community/u/#{user_id}" if user_id.present?
  end
end
