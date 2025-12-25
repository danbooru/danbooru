require "test_helper"

module Source::Tests::URL
  class NicoSeigaUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "http://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf",
          "http://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893",
          "https://lohas.nicoseiga.jp/o/971eb8af9bbcde5c2e51d5ef3a2f62d6d9ff5552/1589933964/3583893",
          "http://seiga.nicovideo.jp/image/source?id=3312222",
          "https://seiga.nicovideo.jp/image/source/3521156",
          "https://sp.seiga.nicovideo.jp/image/source/3521156",
          "https://seiga.nicovideo.jp/image/redirect?id=3583893",
          "https://lohas.nicoseiga.jp/thumb/2163478i",
          "https://lohas.nicoseiga.jp/thumb/4744553p",
          "https://dcdn.cdn.nimg.jp/priv/62a56a7f67d3d3746ae5712db9cac7d465f4a339/1592186183/10466669",
          "https://drm.cdn.nicomanga.jp/image/d4a2faa68ec34f95497db6601a4323fde2ccd451_9537/8017978p?1570012695",
        ],
        page_urls: [
          "https://seiga.nicovideo.jp/seiga/im520647",
          "https://sp.seiga.nicovideo.jp/seiga/im3521156",
          "https://www.nicovideo.jp/watch/sm36465441",
          "https://www.nicovideo.jp/watch/nm36465441",
          "https://www.nicovideo.jp/watch/so40968812",
          "https://www.nicovideo.jp/watch/1488526447",
          "https://nicovideo.jp/watch/sm36465441",
          "https://sp.nicovideo.jp/watch/sm36465441",
          "https://embed.nicovideo.jp/watch/sm36465441",
          "https://nico.ms/im10922621",
          "https://nico.ms/sm36465441",
          "https://nico.ms/nm36465441",
          "https://nico.ms/so40968812",
          "https://nico.ms/1488526447",

          # manga
          "https://seiga.nicovideo.jp/watch/mg316708",
          "https://sp.seiga.nicovideo.jp/watch/mg925907",
          "https://manga.nicovideo.jp/watch/mg566097",
          "https://sp.manga.nicovideo.jp/watch/mg925907",
          "https://nico.ms/mg310193",
        ],
        profile_urls: [
          "https://seiga.nicovideo.jp/user/illust/456831",
          "https://ext.seiga.nicovideo.jp/user/illust/20542122",
          "http://seiga.nicovideo.jp/manga/list?user_id=23839737",
          "https://www.nicovideo.jp/user/4572975",
          "https://nicovideo.jp/user/4572975",
          "https://sp.nicovideo.jp/user/4572975",
          "https://commons.nicovideo.jp/user/696839",
          "https://q.nicovideo.jp/users/18700356",
          "https://dic.nicovideo.jp/u/11141663",
          "https://3d.nicovideo.jp/users/109584",
          "https://3d.nicovideo.jp/u/siobi",
          "http://game.nicovideo.jp/atsumaru/users/7757217",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://seiga.nicovideo.jp",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663",
                             page_url: "https://seiga.nicovideo.jp/seiga/im4937663",)

      url_parser_should_work("https://seiga.nicovideo.jp/watch/mg316708",
                             page_url: "https://manga.nicovideo.jp/watch/mg316708",)

      url_parser_should_work("https://sp.manga.nicovideo.jp/watch/mg316708",
                             page_url: "https://manga.nicovideo.jp/watch/mg316708",)
    end
  end
end
