# frozen_string_literal: true

# Image URLs:
#
# * https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg (page: https://www.nijie.info/view.php?id=64240)
# * https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png (page: https://www.nijie.info/view.php?id=218856)
# * https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png (page: http://nijie.info/view.php?id=218856)
# * https://pic01.nijie.info/nijie_picture/diff/main/218856_1_236014_20170620101330.png
# * https://pic05.nijie.info/nijie_picture/diff/main/559053_20180604023346_1.png (page: http://nijie.info/view_popup.php?id=265428#diff_2)
# * https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png (page: http://nijie.info/view_popup.php?id=287736#diff_2)
# * https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png (page: https://www.nijie.info/view.php?id=218856)
#
# * https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg
#
# Unhandled:
#
# * https://pic01.nijie.info/nijie_picture/20120211210359.jpg
# * https://pic01.nijie.info/nijie_picture/2012021022424020120210.jpg
# * https://pic01.nijie.info/nijie_picture/diff/main/2012061023480525712_0.jpg
# * https://pic05.nijie.info/dojin_main/dojin_sam/1_2768_20180429004232.png
# * https://pic04.nijie.info/horne_picture/diff/main/56095_20160403221810_0.jpg
# * https://pic04.nijie.info/omata/4829_20161128012012.png (page: http://nijie.info/view_popup.php?id=33224#diff_3)
#
# Preview URLs:
#
# * https://pic01.nijie.info/__rs_l120x120/nijie_picture/diff/main/218856_0_236014_20170620101329.png
# * https://pic03.nijie.info/__rs_l120x120/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/__rs_l170x170/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/__rs_l650x650/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/__rs_cns350x350/nijie_picture/236014_20170620101426_0.png
# * https://pic03.nijie.info/small_light(dh=150,dw=150,q=100)/nijie_picture/236014_20170620101426_0.png
#
# Page URLs:
#
# * https://nijie.info/view.php?id=167755 (deleted post)
# * https://nijie.info/view.php?id=218856
# * https://nijie.info/view_popup.php?id=218856
# * https://nijie.info/view_popup.php?id=218856#diff_1
# * https://www.nijie.info/view.php?id=218856
# * https://sp.nijie.info/view.php?id=218856
#
# Profile URLs
#
# * https://nijie.info/members.php?id=236014
# * https://nijie.info/members_illust.php?id=236014
#
# Doujin
#
# * http://nijie.info/view.php?id=384548
# * http://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg (NSFW)
# * http://pic.nijie.net/01/__rs_l120x120/dojin_main/dojin_sam/20120213044700%E3%82%B3%E3%83%94%E3%83%BC%20%EF%BD%9E%200011%E3%81%AE%E3%82%B3%E3%83%94%E3%83%BC.jpg

class Source::URL::Nijie < Source::URL
  attr_reader :work_id, :user_id

  def self.match?(url)
    url.domain.in?(%w[nijie.net nijie.info])
  end

  def parse
    case [domain, *path_segments]

    # https://nijie.info/view.php?id=167755 (deleted post)
    # https://nijie.info/view.php?id=218856
    # https://nijie.info/view_popup.php?id=218856
    # https://nijie.info/view_popup.php?id=218856#diff_1
    # https://www.nijie.info/view.php?id=218856
    # https://sp.nijie.info/view.php?id=218856
    in "nijie.info", ("view.php" | "view_popup.php") if params[:id].present?
      @work_id = params[:id]

    # https://nijie.info/members.php?id=236014
    # https://nijie.info/members_illust.php?id=236014
    in "nijie.info", ("members.php" | "members_illust.php") if params[:id].present?
      @user_id = params[:id]

    # https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg
    in _, "nijie_picture", /^\d{2}$/, "nijie", /^\d{2}$/, /^\d{2}$/, user_id, "illust", _ if image_url?
      @user_id = user_id

    # https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png (page: http://nijie.info/view.php?id=218856)
    # https://pic01.nijie.info/nijie_picture/diff/main/218856_1_236014_20170620101330.png
    # https://pic05.nijie.info/nijie_picture/diff/main/559053_20180604023346_1.png (page: http://nijie.info/view_popup.php?id=265428#diff_2)
    # https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png (page: http://nijie.info/view_popup.php?id=287736#diff_2)
    # https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg (page: https://www.nijie.info/view.php?id=64240)
    # https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png (page: https://www.nijie.info/view.php?id=218856)
    # https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png (page: https://www.nijie.info/view.php?id=218856)
    # https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg
    in [*, "nijie_picture", *] if image_url?
      parse_filename

    # http://pic.nijie.net/01/dojin_main/dojin_sam/20120213044700コピー ～ 0011のコピー.jpg (NSFW)
    # http://pic.nijie.net/01/__rs_l120x120/dojin_main/dojin_sam/20120213044700コピー ～ 0011のコピー.jpg
    in _, /^\d+$/, *subdir, "dojin_main", "dojin_sam", file if image_url?
      nil

    else
    end
  end

  def parse_filename
    case filename.split("_")

    # 28310_20131101215959.jpg
    # 236014_20170620101426_0.png
    # 829001_20190620004513_0.mp4
    # 559053_20180604023346_1.png
    in /^\d+$/ => user_id, /^\d{14}$/ => timestamp, *rest
      @user_id = user_id

    # 218856_0_236014_20170620101329.png
    in /^\d+$/ => work_id, /^\d+$/, /^\d+$/ => user_id, /^\d{14}$/ => timestamp
      @work_id, @user_id = work_id, user_id

    # 287736_161475_20181112032855_1.png
    in /^\d+$/ => work_id, /^\d+$/ => user_id, /^\d{14}$/ => timestamp, /^\d+$/
      @work_id, @user_id = work_id, user_id

    else
    end
  end

  def image_url?
    subdomain.to_s.starts_with?("pic")
  end

  def preview_image_url
    to_s.gsub(/nijie_picture/, "__rs_l170x170/nijie_picture") if image_url?
  end

  def full_image_url
    to_s.remove(%r{__rs_\w+/}i).gsub("http:", "https:") if image_url?
  end
end
