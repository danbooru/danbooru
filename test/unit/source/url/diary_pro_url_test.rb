require "test_helper"

module Source::Tests::URL
  class DiaryProUrlTest < ActiveSupport::TestCase
    context "Diary Pro URLs" do
      should be_image_url(
        "http://nekomataya.net/diarypro/data/upfile/66-1.jpg",
        "http://www117.sakura.ne.jp/~cat_rice/diarypro/data/upfile/31-1.jpg",
      )

      should be_page_url(
        "https://www.johnmung.info/diarypro/diary.cgi?mode=image&upfile=32-1.jpg",
        "https://johnmung.info/diarypro/diary.cgi?no=31",
      )

      should_not be_page_url(
        "https://johnmung.info/diarypro/diary.cgi",
      )

      should parse_url("http://nekomataya.net/diarypro/data/upfile/216-1.jpg").into(page_url: "http://nekomataya.net/diarypro/diary.cgi?no=216")
      should parse_url("http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg").into(page_url: "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716")
    end
  end
end
