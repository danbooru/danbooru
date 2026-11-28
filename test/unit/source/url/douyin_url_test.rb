require "test_helper"

module Source::Tests::URL
  class DouyinUrlTest < ActiveSupport::TestCase
    context "Douyin URLs" do
      should be_image_url(
        "https://p3-pc-sign.douyinpic.com/tos-cn-i-0813c000-ce/oUlDIBeDAGIBMAAAGeSKeL04aTgHBQnI2fgCvA~noop.jpeg?biz_tag=pcweb_cover&from=327834062&lk3s=138a59ce&s=PackSourceEnum_PUBLISH&se=false&x-expires=1794412800&x-signature=%2B%2BOarl8Jm0TbA4x4ArqwYBIJ5z8%3D",
      )

      should be_page_url(
        "https://www.douyin.com/video/7127940372856114467",
        "https://www.douyin.com/note/7698000683710743973",
        "https://www.iesdouyin.com/share/video/7524660855435988284/?region=CN&mid=7524660840075660073&u_code=1b5gh7ddk6j8",
        "https://www.iesdouyin.com/share/note/7698000683710743973/",
        "https://www.douyin.com/user/MS4wLjABAAAAEKnfa654JAJ_N5lgZDQluwsxmY0lhfmEYNQBBkwGG98?modal_id=7127940372856114467",
        "https://www.douyin.com/discover?modal_id=7127940372856114467",
        "https://www.douyin.com/jingxuan?modal_id=7127940372856114467",
      )

      should be_image_url(
        "https://www.douyin.com/aweme/v1/play/?video_id=v1e00fgi0000d1mfe5vog65vhen11m4g&line=0&file_id=c91511bc740e4ffb9e77e92f50164e1f&sign=26f6b5b6d115ff53471a76094882d490&is_play_url=1&source=PackSourceEnum_AWEME_DETAIL&biz_sign=NRPI1l",
      )

      should be_profile_url(
        "https://www.douyin.com/user/MS4wLjABAAAAEKnfa654JAJ_N5lgZDQluwsxmY0lhfmEYNQBBkwGG98",
      )

      should be_bad_link(
        "https://p3-pc-sign.douyinpic.com/tos-cn-i-0813c000-ce/oUlDIBeDAGIBMAAAGeSKeL04aTgHBQnI2fgCvA~noop.jpeg?biz_tag=pcweb_cover&from=327834062&lk3s=138a59ce&s=PackSourceEnum_PUBLISH&se=false&x-expires=1794412800&x-signature=%2B%2BOarl8Jm0TbA4x4ArqwYBIJ5z8%3D",
      )

      should be_bad_source(
        "https://v.douyin.com/znwIiWQwdiU/",
      )

      should parse_url("https://www.iesdouyin.com/share/note/7698000683710743973/").into(
        page_url: "https://www.douyin.com/note/7698000683710743973",
      )

      should parse_url("https://www.iesdouyin.com/share/video/7524660855435988284/?region=CN").into(
        page_url: "https://www.douyin.com/video/7524660855435988284",
      )

      should parse_url("https://www.douyin.com/user/MS4wLjABAAAAEKnfa654JAJ_N5lgZDQluwsxmY0lhfmEYNQBBkwGG98?modal_id=7127940372856114467").into(
        post_id: "7127940372856114467",
        page_url: "https://www.douyin.com/video/7127940372856114467",
        profile_url: "https://www.douyin.com/user/MS4wLjABAAAAEKnfa654JAJ_N5lgZDQluwsxmY0lhfmEYNQBBkwGG98",
      )

      should parse_url("https://www.douyin.com/discover?modal_id=abc").into(
        post_id: nil,
        page_url: nil,
      )

      should parse_url("https://v.douyin.com/znwIiWQwdiU/").into(
        redirect_id: "znwIiWQwdiU",
      )

      should parse_url("https://v.douyin.com/..%2Fx").into(redirect_id: nil)
      should parse_url("https://v.douyin.com/znwIiWQwdiU%3Fx=1").into(redirect_id: nil)
      should parse_url("https://www.douyin.com/video/7127940372856114467%3Fx=1").into(post_id: nil, page_url: nil)
      should parse_url("https://www.douyin.com/note/..%2F..%2Faweme%2Fv1%2Fweb%2Faweme%2Fpost").into(post_id: nil, page_url: nil)
      should parse_url("https://www.iesdouyin.com/share/video/..%2Fx/").into(post_id: nil, page_url: nil)
      should parse_url("https://www.douyin.com/user/MS4w..%2F..%2Fx").into(sec_uid: nil, profile_url: nil)
      should parse_url("https://www.douyin.com/discover?modal_id=1%26x=2").into(post_id: nil, page_url: nil)
      should parse_url("https://www.douyin.com/discover?modal_id[]=1").into(post_id: nil, page_url: nil)
    end

    should parse_url("https://www.douyin.com/video/7127940372856114467").into(site_name: "Douyin")
  end
end
