# frozen_string_literal: true

module Source
  class URL::Pixiv < Source::URL
    attr_reader :work_id, :image_type, :page, :date, :username, :user_id, :novel_id, :novel_series_id, :novel_embedded_image_id

    def self.match?(url)
      return false if Source::URL::Fanbox.match?(url) || Source::URL::PixivSketch.match?(url) || Source::URL::PixivComic.match?(url) || Source::URL::Booth.match?(url)

      url.domain.in?(%w[pximg.net pixiv.net pixiv.me pixiv.cc p.tl])
    end

    def parse
      case [subdomain, domain, *path_segments]
      # https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
      # https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg
      # https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip
      # https://i.pximg.net/img-original/img/2019/05/27/17/59/33/74932152_ugoira0.jpg
      # https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
      # https://i.pximg.net/custom-thumb/img/2022/03/08/00/00/56/96755248_p0_custom1200.jpg

      # https://i.pximg.net/c/ic0:900:1280/img-original/img/2024/04/26/13/03/41/118168794_p8.jpg
      # https://i.pximg.net/c/ic1280:900:2560/img-original/img/2024/04/26/13/03/41/118168794_p8.jpg
      # https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg
      # https://i.pximg.net/c/360x360_70/custom-thumb/img/2022/03/08/00/00/56/96755248_p0_custom1200.jpg
      # https://i.pximg.net/c/240x240/img-master/img/2017/04/04/08/57/38/62247364_master1200.jpg
      # http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg

      # https://i.pximg.net/c/600x600/novel-cover-master/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4_master1200.jpg (sample image; ci = cover image)
      # https://i.pximg.net/novel-cover-original/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4.jpg (full image)
      # https://i.pximg.net/novel-cover-original/img/2018/04/02/19/38/29/9434677_6ab6c651d5568ff39e2ba6ab45edaf28.jpg (assumed novel cover image)
      # http://i1.pixiv.net/novel-cover-original/img/2016/11/11/20/11/46/7463785_0e2446dc1671dd3a4937dfaee39c227f.jpg

      # https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg (sample image)
      # https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg (full image; tei = text embedded image, image embedded in novel text)

      # https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg (sample image; sci = series cover image)
      # https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg (full image)
      in *, ("img-original" | "img-master" | "img-zip-ugoira" | "img-inf" | "custom-thumb" | "novel-cover-original" | "novel-cover-master") => image_type, "img", year, month, day, hour, min, sec, _ if image_url?
        @image_type = image_type
        @date = [year, month, day, hour, min, sec]
        parse_filename

      # http://img18.pixiv.net/img/evazion/14901720.png
      # http://i2.pixiv.net/img18/img/evazion/14901720.png
      # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
      # http://i2.pixiv.net/img18/img/evazion/14901720_s.png
      # http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png
      # http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg
      in *, "img", username, file if image_url?
        parse_filename
        @username = username

      # https://www.pixiv.net/en/artworks/46324488
      # https://www.pixiv.net/artworks/46324488
      in _, "pixiv.net", *, "artworks", work_id
        @work_id = work_id

      # https://www.pixiv.net/novel/show.php?id=9434677
      # http://www.pixiv.net/novel/show.php?id=235466&mode=cover
      in _, "pixiv.net", "novel", "show.php" if params[:id].present?
        @novel_id = params[:id]

      # https://embed.pixiv.net/novel.php?id=18588585&mdate=20221102100423 (twitter embed image)
      in "embed", "pixiv.net", "novel.php" if params[:id].present?
        @novel_id = params[:id]

      # https://www.pixiv.net/novel/series/9593812
      in _, "pixiv.net", "novel", "series", /^\d+$/ => novel_series_id
        @novel_series_id = novel_series_id

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

      # http://p.tl/i/40009777
      in _, "p.tl", "i", work_id
        @work_id = work_id

      # http://p.tl/m/755548
      in _, "p.tl", "m", user_id
        @user_id = user_id

      # http://p.tl/dcYB/ (dead; Pixiv's URL shortening service, closed in 2017)
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

      # http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg
      in /^\d+$/ => work_id, "big", /^p\d+$/ => page
        @work_id = work_id
        @page = page.delete_prefix("p").to_i

      # https://i.pximg.net/c/600x600/novel-cover-master/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4_master1200.jpg (sample image; ci = cover image)
      # https://i.pximg.net/novel-cover-original/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4.jpg (full image)
      # https://i.pximg.net/novel-cover-original/img/2018/04/02/19/38/29/9434677_6ab6c651d5568ff39e2ba6ab45edaf28.jpg (assumed novel cover image)
      in /^(ci)?\d+$/ => novel_id, /^\h{32}$/, *rest
        @novel_id = novel_id.delete_prefix("ci")

      # https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg (sample image; sci = series cover image)
      # https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg (full image)
      in /^sci\d+$/ => novel_series_id, /^\h{32}$/, *rest
        @novel_series_id = novel_series_id.delete_prefix("sci")

      # https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg (sample image)
      # https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg (full image; tei = text embedded image, image embedded in novel text)
      in /^tei\d+$/ => novel_embedded_image_id, /^\h{32}$/, *rest
        @novel_embedded_image_id = novel_embedded_image_id.delete_prefix("tei")

      # https://i.pximg.net/c/240x240/img-master/img/2017/04/04/08/57/38/62247364_master1200.jpg
      # http://i2.pixiv.net/img18/img/evazion/14901720.png
      # http://i2.pixiv.net/img18/img/evazion/14901720_m.png
      # http://i2.pixiv.net/img18/img/evazion/14901720_s.png
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg
      # http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png
      # https://i.pximg.net/img-original/img/2019/05/27/17/59/33/74932152_ugoira0.jpg
      # https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip
      in /^\d+$/ => work_id, *rest
        @work_id = work_id

      # http://i4.pixiv.net/img96/img/masao_913555/novel/4472318.jpg
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

    def is_ugoira?
      # https://i.pximg.net/img-original/img/2019/05/27/17/59/33/74932152_ugoira0.jpg
      # https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip
      filename.include?("ugoira")
    end

    def full_image_url
      # https://i.pximg.net/c/ic0:400:1280/img-original/img/2010/10/20/00/11/54/13992705_p0.png
      # https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
      # https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip
      # https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png
      # http://i1.pixiv.net/novel-cover-original/img/2016/11/11/20/11/46/7463785_0e2446dc1671dd3a4937dfaee39c227f.jpg
      # https://i.pximg.net/novel-cover-original/img/2018/04/02/19/38/29/9434677_6ab6c651d5568ff39e2ba6ab45edaf28.jpg
      # https://i.pximg.net/novel-cover-original/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4.jpg
      # https://i.pximg.net/novel-cover-original/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc.jpg
      # https://i.pximg.net/novel-cover-original/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5.jpg
      if image_url? && image_type.in?(%w[img-original img-zip-ugoira novel-cover-original]) && date.present?
        "https://i.pximg.net/#{image_type}/img/#{date.join("/")}/#{basename}"
      end
    end

    def candidate_full_image_urls
      return [] unless image_url? && date.present?

      # https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg
      # https://i.pximg.net/c/360x360_70/custom-thumb/img/2022/03/08/00/00/56/96755248_p0_custom1200.jpg
      # https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg
      # https://i.pximg.net/custom-thumb/img/2022/03/08/00/00/56/96755248_p0_custom1200.jpg
      if work_id.present? && page.present?
        %w[jpg png gif].map { |ext| "https://i.pximg.net/img-original/img/#{date.join("/")}/#{work_id}_p#{page}.#{ext}" }

      # https://i.pximg.net/c/600x600/novel-cover-master/img/2022/10/23/17/33/05/ci18588585_2332b5586ce5a9b039859254b6b220d4_master1200.jpg
      # https://i.pximg.net/c/480x960/novel-cover-master/img/2022/10/23/17/31/13/sci9593812_3eb12772f4715a9700d44ffee1107adc_master1200.jpg
      # https://i.pximg.net/c/1200x1200/novel-cover-master/img/2022/11/02/10/04/22/tei62073304808_46e2ad585d3b76d042a1f12ea49625e5_master1200.jpg
      elsif image_type == "novel-cover-master"
        %w[jpg png gif].map { |ext| "https://i.pximg.net/novel-cover-original/img/#{date.join("/")}/#{filename[/^[a-z]*\d+_\h{32}/]}.#{ext}" }
      else
        []
      end
    end

    def page_url
      if work_id.present?
        "https://www.pixiv.net/artworks/#{work_id}"
      elsif novel_id.present?
        "https://www.pixiv.net/novel/show.php?id=#{novel_id}"
      elsif novel_series_id.present?
        "https://www.pixiv.net/novel/series/#{novel_series_id}"
      end
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
