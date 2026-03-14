require "test_helper"

module Source::Tests::URL
  class DiaryProUrlTest < ActiveSupport::TestCase
    context "Diary Pro URLs" do
      should parse_url("http://nekomataya.net/diarypro/data/upfile/216-1.jpg").into(page_url: "http://nekomataya.net/diarypro/diary.cgi?no=216")

      should parse_url("http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg").into(page_url: "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716")
    end
  end
end
