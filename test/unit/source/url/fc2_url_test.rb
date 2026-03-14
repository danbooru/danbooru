require "test_helper"

module Source::Tests::URL
  class Fc2UrlTest < ActiveSupport::TestCase
    context "Fc2 URLs" do
      should be_image_url(
        "http://onidocoro.blog14.fc2.com/file/20071003061150.png",
        "http://blog23.fc2.com/m/mosha2/file/uru.jpg",
        "http://blog.fc2.com/g/genshi/file/20070612a.jpg",
        "http://blog-imgs-63-origin.fc2.com/y/u/u/yuukyuukikansya/140817hijiri02.jpg",
        "http://blog-imgs-61.fc2.com/o/m/o/omochi6262/20130402080220583.jpg",
        "http://blog.fc2.com/g/b/o/gbot/20071023195141.jpg",
        "http://diary.fc2.com/user/yuuri/img/2005_12/26.jpg",
      )

      should be_page_url(
        "http://hosystem.blog36.fc2.com/blog-entry-37.html",
        "http://swordsouls.blog131.fc2blog.us/blog-entry-376.html",
        "http://oekakigakusyuu.blog97.fc2.com/?m&no=320",
        "http://abk00.blog71.fc2.com/?no=3052",
        "http://niyamalog.blog.fc2.com/img/20170330Xray6z7P/",
        "http://niyamalog.blog.fc2.com/img/bokuomapop.jpg/",
        "http://swordsouls.blog131.fc2blog.us/img/20141009132121fb7.jpg/",
        "http://alternatif.blog26.fc2.com/?mode=image&filename=rakugaki10.jpg",
        "http://swordsouls.blog131.fc2blog.us/?mode=image&filename=20141009132121fb7.jpg",
      )

      should be_profile_url(
        "http://silencexs.blog.fc2.com",
        "http://794ancientkyoto.web.fc2.com",
        "http://yorokobi.x.fc2.com",
        "https://lilish28.bbs.fc2.com",
        "http://jpmaid.h.fc2.com",
        "http://swordsouls.blog131.fc2blog.net",
        "http://swordsouls.blog131.fc2blog.us",
        "http://xkilikox.fc2web.com/image/haguruma.html",
        "http://oss4224.web.fc2.com/こ",
      )

      should parse_url("http://diary.fc2.com/user/kazuharoom/img/2020_1/29.jpg").into(
        page_url: "http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom?Y=2020&M=1&D=29",
      )

      should parse_url("http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom/?Y=2012&M=10&D=22").into(
        profile_url: "http://diary.fc2.com/cgi-sys/ed.cgi/kazuharoom",
      )

      should parse_url("http://toritokaizoku.web.fc2.com/tori.html").into(
        profile_url: "http://toritokaizoku.web.fc2.com/tori.html",
      )

      should parse_url("http://xkilikox.fc2web.com/image/haguruma.html").into(
        profile_url: "http://xkilikox.fc2web.com/image/haguruma.html",
      )

      should parse_url("http://xkilikox.fc2web.com/image/haguruma00.jpg").into(
        profile_url: "http://xkilikox.fc2web.com",
      )
    end
  end
end
