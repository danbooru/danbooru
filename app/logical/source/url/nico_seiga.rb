# frozen_string_literal: true

# NicoSeiga has two main page types, regular single-image illusts and mangas:
#
# * https://seiga.nicovideo.jp/seiga/im2163478
# * https://seiga.nicovideo.jp/watch/mg122274
#
# It's not possible to tell from the URL alone whether an image belongs to a regular illust or a manga:
#
# * https://lohas.nicoseiga.jp/priv/2e76be4c553c571b5a81e6ea1a69ab1367f02a41/1646904833/2163478 (page: https://seiga.nicovideo.jp/seiga/im2163478)
# * https://lohas.nicoseiga.jp/priv/49807693c31ed226818b9167e8e87561dd19a445/1646904643/4744553 (page: https://seiga.nicovideo.jp/watch/mg122274)
#
# You can tell them apart like this:
#
# * https://seiga.nicovideo.jp/image/source/2163478 (redirects to https://lohas.nicoseiga.jp/o/e69bba4bd6c1baaae460452bac3f29e7080ad723/1646902784/3521156)
# * https://seiga.nicovideo.jp/image/source/4744553 (redirects to https://lohas.nicoseiga.jp/priv/54142f438f4effb937e6b484395b478305ca17f2/1646905053/4744553)
#
# Unhandled URLs
#
# * https://www.nicovideo.jp/watch/sm36465441
# * https://www.nicovideo.jp/watch/nm20676560
# * https://lohas.nicoseiga.jp/material/5746c5/4459092
# * https://dic.nicovideo.jp/oekaki/52833.png
#
module Source
  class URL::NicoSeiga < Source::URL
    attr_reader :illust_id, :manga_id, :image_id, :user_id, :username, :profile_url

    def self.match?(url)
      url.domain.in?(%w[nicovideo.jp nicoseiga.jp nicomanga.jp nimg.jp])
    end

    def site_name
      "Nico Seiga"
    end

    def parse
      case [host, *path_segments]

      # https://seiga.nicovideo.jp/seiga/im520647 (anonymous artist)
      # https://seiga.nicovideo.jp/seiga/im3521156
      # https://sp.seiga.nicovideo.jp/seiga/im3521156
      in /seiga\.nicovideo\.jp$/, "seiga", /^im(\d+)/ => illust_id
        @illust_id = $1
        @image_id = $1

      # https://seiga.nicovideo.jp/watch/mg316708
      # https://sp.seiga.nicovideo.jp/watch/mg316708
      in /seiga\.nicovideo\.jp$/, "watch", /^mg(\d+)/ => manga_id
        @manga_id = $1

      # https://seiga.nicovideo.jp/image/source/3521156 (single image; page: https://seiga.nicovideo.jp/seiga/im3312222)
      # https://seiga.nicovideo.jp/image/source/4744553 (manga image; page: https://seiga.nicovideo.jp/watch/mg122274)
      #
      # https://seiga.nicovideo.jp/image/source/3521156 redirects to the html page https://lohas.nicoseiga.jp/o/e69bba4bd6c1baaae460452bac3f29e7080ad723/1646902784/3521156, which contains the image https://lohas.nicoseiga.jp/priv/e69bba4bd6c1baaae460452bac3f29e7080ad723/1646902784/3521156.
      # https://seiga.nicovideo.jp/image/source/4744553 redirects to the direct image https://lohas.nicoseiga.jp/priv/54142f438f4effb937e6b484395b478305ca17f2/1646905053/4744553
      in "seiga.nicovideo.jp", "image", "source", image_id
        @image_id = image_id

      # https://seiga.nicovideo.jp/image/source?id=3521156 (redirects to https://lohas.nicoseiga.jp/o/75dfbf6404732969ded3937b89bc41d77420debe/1646906075/3521156)
      # https://seiga.nicovideo.jp/image/redirect?id=3583893 (redirects to https://seiga.nicovideo.jp/seiga/im3583893)
      in "seiga.nicovideo.jp", "image", ("redirect" | "source") if params[:id].present?
        @image_id = params[:id]

      # https://lohas.nicoseiga.jp/o/971eb8af9bbcde5c2e51d5ef3a2f62d6d9ff5552/1589933964/3583893 (page: https://seiga.nicovideo.jp/seiga/im3583893)
      # https://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893 (page: https://seiga.nicovideo.jp/seiga/im3583893)
      # https://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf (page: https://seiga.nicovideo.jp/seiga/im3521156)
      in "lohas.nicoseiga.jp", ("priv" | "o"), *, /^\d+$/ => image_id
        @image_id = image_id

      # https://lohas.nicoseiga.jp/thumb/2163478i (page: https://seiga.nicovideo.jp/seiga/im2163478, image: https://lohas.nicoseiga.jp/priv/2e76be4c553c571b5a81e6ea1a69ab1367f02a41/1646904833/2163478)
      # https://lohas.nicoseiga.jp/thumb/1591081q (page: https://seiga.nicovideo.jp/seiga/im1591081, image: https://lohas.nicoseiga.jp/priv/b6a8fc0327624e57f43c29f6e7f18797406681f7/1646904868/1591081)
      in "lohas.nicoseiga.jp", "thumb", /^(\d+)[iq]$/ => image_id
        @illust_id = $1
        @image_id = $1

      # https://lohas.nicoseiga.jp/thumb/4744553p (page: https://seiga.nicovideo.jp/watch/mg122274, image: https://lohas.nicoseiga.jp/priv/49807693c31ed226818b9167e8e87561dd19a445/1646904643/4744553)
      in "lohas.nicoseiga.jp", "thumb", /^(\d+)p$/ => image_id
        @illust_id = $1

      # https://dcdn.cdn.nimg.jp/priv/62a56a7f67d3d3746ae5712db9cac7d465f4a339/1592186183/10466669
      # https://dcdn.cdn.nimg.jp/nicoseiga/lohas/o/8ba0a9b2ea34e1ef3b5cc50785bd10cd63ec7e4a/1592187477/10466669
      in "dcdn.cdn.nimg.jpg", *, /^\d+$/ => image_id
        @image_id = image_id

      # https://deliver.cdn.nicomanga.jp/thumb/aHR0cHM6Ly9kZWxpdmVyLmNkbi5uaWNvbWFuZ2EuanAvdGh1bWIvODEwMDk2OHA_MTU2NTY5OTg4MA.webp (page: https://seiga.nicovideo.jp/watch/mg316708, full image: https://lohas.nicoseiga.jp/priv/1f6d38ef2ba6fc9d9e27823babc4cf721cef16ec/1646906617/8100969)
      in "deliver.cdn.nicomanga.jp", *rest
        # unhandled

      # https://seiga.nicovideo.jp/user/illust/456831
      # https://sp.seiga.nicovideo.jp/user/illust/20542122
      # https://ext.seiga.nicovideo.jp/user/illust/20542122
      in /seiga\.nicovideo\.jp$/, "user", "illust", user_id
        @user_id = user_id
        @profile_url = "https://seiga.nicovideo.jp/user/illust/#{user_id}"

      # http://seiga.nicovideo.jp/manga/list?user_id=23839737
      # http://sp.seiga.nicovideo.jp/manga/list?user_id=23839737
      in /seiga\.nicovideo\.jp$/, "manga", "list" if params[:user_id].present?
        @user_id = params[:user_id]
        @profile_url = "https://seiga.nicovideo.jp/manga/list?user_id=#{params[:user_id]}"

      # https://www.nicovideo.jp/user/4572975
      # https://www.nicovideo.jp/user/20446930/mylist/28674289
      in ("www.nicovideo.jp"), "user", /^\d+$/ => user_id, *rest
        @user_id = user_id
        @profile_url = "https://www.nicovideo.jp/user/#{user_id}"

      # https://commons.nicovideo.jp/user/696839
      in "commons.nicovideo.jp", "user", /^\d+$/ => user_id, *rest
        @user_id = user_id
        @profile_url = "https://commons.nicovideo.jp/user/#{user_id}"

      # https://q.nicovideo.jp/users/18700356
      in "q.nicovideo.jp", "users", /^\d+$/ => user_id, *rest
        @user_id = user_id
        @profile_url = "https://q.nicovideo.jp/users/#{user_id}"

      # https://dic.nicovideo.jp/u/11141663
      in "dic.nicovideo.jp", "u", /^\d+$/ => user_id, *rest
        @user_id = user_id
        @profile_url = "https://dic.nicovideo.jp/u/#{user_id}"

      # https://3d.nicovideo.jp/users/109584
      # https://3d.nicovideo.jp/users/29626631/works
      in "3d.nicovideo.jp", "users", /^\d+$/ => user_id, *rest
        @user_id = user_id
        @profile_url = "https://3d.nicovideo.jp/users/#{user_id}"

      # https://3d.nicovideo.jp/u/siobi
      in "3d.nicovideo.jp", "u", username, *rest
        @username = username
        @profile_url = "https://3d.nicovideo.jp/u/#{username}"

      # http://game.nicovideo.jp/atsumaru/users/7757217
      in "game.nicovideo.jp", "atsumaru", "users", /^\d+$/ => user_id, *rest
        @user_id = user_id
        @profile_url = "https://game.nicovideo.jp/atsumaru/users/#{user_id}"

      else
      end
    end

    def page_url
      if illust_id.present?
        "https://seiga.nicovideo.jp/seiga/im#{illust_id}"
      elsif manga_id.present?
        "https://seiga.nicovideo.jp/watch/mg#{manga_id}"
      elsif image_id.present?
        "https://seiga.nicovideo.jp/image/source/#{image_id}"
      end
    end
  end
end
