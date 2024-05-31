# frozen_string_literal: true

# Unhandled:
#
# http://www.tinami.com/comic/naomao
# http://www.tinami.com/comic/naomao/1
# http://www.tinami.com/comic/jaga/052.php
# http://www.tinami.com/gallery/img/29aono.jpg
# http://www.tinami.com/today/artworks/t071127_147092.jpg

class Source::URL::Tinami < Source::URL
  attr_reader :user_id, :profile_id, :work_id

  def self.match?(url)
    url.domain.in?(%w[tinami.com tinami.jp])
  end

  def parse
    case [host, *path_segments]

    # https://img.tinami.com/illust/img/287/497c8a9dc60e6.jpg
    # https://img.tinami.com/illust2/img/419/5013fde3406b9.jpg (page: https://www.tinami.com/view/461459)
    # https://img.tinami.com/illust2/L/452/622f7aa336bf3.gif (thumbnail)
    # https://img.tinami.com/comic/naomao/naomao_001_01.jpg (page: http://www.tinami.com/comic/naomao/1)
    # https://img.tinami.com/comic/naomao/naomao_002_01.jpg (page: http://www.tinami.com/comic/naomao/2)
    # https://img.tinami.com/comic/naomao/naomao_topillust.gif
    in "img.tinami.com", *rest
      nil

    # http://www.tinami.com/creator/profile/1624
    in _, "creator", "profile", user_id
      @user_id = user_id

    # https://www.tinami.com/search/list?prof_id=1624
    in _, "search", "list" if params[:prof_id].present?
      @user_id = params[:prof_id]

    # The /profile/:id URL is not the same as the /creator/profile/:id URL
    # http://www.tinami.com/profile/1182 (creator: http://www.tinami.com/creator/profile/1624)
    # http://www.tinami.jp/p/1182
    in _, ("profile" | "p"), profile_id
      @profile_id = profile_id

    # https://www.tinami.com/view/461459
    in _, "view", work_id
      @work_id = work_id

    # https://www.tinami.com/view/tweet/card/461459 (sample image)
    in _, "view", "tweet", "card", work_id
      @work_id = work_id

    else
      nil
    end
  end

  def image_url?
    host == "img.tinami.com" || path.starts_with?("/view/tweet/card/")
  end

  def page_url
    "https://www.tinami.com/view/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://www.tinami.com/creator/profile/#{user_id}" if user_id.present?
  end
end
