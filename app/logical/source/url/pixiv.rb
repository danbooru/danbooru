# frozen_string_literal: true

module Source
  class URL::Pixiv < Source::URL
    attr_reader :work_id, :image_type, :page, :username, :user_id

    def self.match?(url)
      return false if Source::URL::Fanbox.match?(url) || Source::URL::PixivSketch.match?(url) || Source::URL::Booth.match?(url)

      url.domain.in?(%w[pximg.net pixiv.net pixiv.me pixiv.cc])
    end

    def parse
      case [subdomain, domain, *path_segments]

      # https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
      # https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg
      # https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg
      # https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip
      # https://i.pximg.net/img-original/img/2019/05/27/17/59/33/74932152_ugoira0.jpg
      # https://i.pximg.net/c/360x360_70/custom-thumb/img/2022/03/08/00/00/56/96755248_p0_custom1200.jpg
      # https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
      #
      # but not:
      #
      # https://i.pximg.net/novel-cover-original/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42.jpg
      in *, ("img-original" | "img-master" | "img-zip-ugoira" | "img-inf" | "custom-thumb") => type, "img", year, month, day, hour, min, sec, file if image_url?
        @image_type = type
        parse_filename

      # http://img18.pixiv.net/img/evazion/14901720.png
      # http://i2.pixiv.net/img18/img/evazion/14901720.png
      # http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png
      in *, "img", username, file if image_url?
        parse_filename
        @username = username

      # https://www.pixiv.net/en/artworks/46324488
      # https://www.pixiv.net/artworks/46324488
      in _, "pixiv.net", *, "artworks", work_id
        @work_id = work_id

      # http://www.pixiv.net/i/18557054
      in _, "pixiv.net", "i", work_id
        @work_id = work_id

      # http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054
      # http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054
      # http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054
      # http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1
      in _, "pixiv.net", "member_illust.php" if params[:illust_id].present?
        @work_id = params[:illust_id]

      # https://www.pixiv.net/member.php?id=339253
      # http://www.pixiv.net/novel/member.php?id=76567
      in _, "pixiv.net", *, "member.php" if params[:id].present?
        @user_id = params[:id]

      # https://www.pixiv.net/u/9202877
      # https://www.pixiv.net/users/9202877
      # https://www.pixiv.net/users/76567/novels
      # https://www.pixiv.net/users/39598149/illustrations?p=1
      # https://www.pixiv.net/user/13569921/series/81967
      in _, "pixiv.net", ("u" | "user" | "users"), user_id, *rest
        @user_id = user_id

      # https://www.pixiv.net/en/users/9202877
      # https://www.pixiv.net/en/users/76567/novels
      in _, "pixiv.net", _, ("u" | "users"), user_id, *rest
        @user_id = user_id

      # https://www.pixiv.net/stacc/noizave
      in _, "pixiv.net", "stacc", username
        @username = username

      # http://www.pixiv.me/noizave
      in _, "pixiv.me", username
        @username = username

      # https://pixiv.cc/zerousagi/
      in _, "pixiv.cc", username
        @username = username

      else
        nil
      end
    end

    def parse_filename
      case filename.split("_")

      # https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
      # https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg
      # http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png
      in /^\d+$/ => work_id, /^p\d+$/ => page, *rest
        @work_id = work_id
        @page = page.delete_prefix("p").to_i

      # https://i.pximg.net/img-original/img/2019/05/27/17/59/33/74932152_ugoira0.jpg
      # https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip
      in /^\d+$/ => work_id, /^ugoira/
        @work_id = work_id
        @ugoira = true

      # https://i.pximg.net/c/240x240/img-master/img/2017/04/04/08/57/38/62247364_master1200.jpg
      # http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg
      # http://i2.pixiv.net/img18/img/evazion/14901720.png
      # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
      # http://i2.pixiv.net/img18/img/evazion/14901720_s.png
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
      in /^\d+$/ => work_id, *rest
        @work_id = work_id

      else
        nil
      end
    end

    def image_url?
      # https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
      # https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png
      # https://i2.pixiv.net/img04/img/syounen_no_uta/46170939_p0.jpg
      # http://img18.pixiv.net/img/evazion/14901720.png
      host.in?(%w[i.pximg.net i-f.pximg.net]) || host.match?(/\A(i\d+|img\d+)\.pixiv\.net\z/)
    end

    def full_image_url?
      image_type.in?(%w[img-original img-zip-ugoira])
    end

    def image_sample?
      image_url? && !full_image_url?
    end

    def is_ugoira?
      @ugoira.present?
    end

    def page_url
      "https://www.pixiv.net/artworks/#{work_id}" if work_id.present?
    end

    def profile_url
      if user_id.present?
        "https://www.pixiv.net/users/#{user_id}"
      elsif username.present?
        "https://www.pixiv.net/stacc/#{username}"
      end
    end
  end
end
