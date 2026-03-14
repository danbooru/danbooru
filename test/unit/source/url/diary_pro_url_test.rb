require "test_helper"

module Source::Tests::URL
  class DiaryProUrlTest < ActiveSupport::TestCase
    context "when extracting attributes" do
      url_parser_should_work(
        "http://nekomataya.net/diarypro/data/upfile/216-1.jpg",
        page_url: "http://nekomataya.net/diarypro/diary.cgi?no=216",
      )

      url_parser_should_work(
        "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?mode=image&upfile=716-3.jpg",
        page_url: "http://akimbo.sakura.ne.jp/diarypro/diary.cgi?no=716",
      )
    end
  end
end
