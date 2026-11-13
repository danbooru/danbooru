require "test_helper"

module Source::Tests::Extractor
  class TiktokExtractorTest < ActiveSupport::ExtractorTestCase
    context "A photo post" do
      strategy_should_work(
        "https://www.tiktok.com/@kasane_tetoee/photo/7684866893383077127",
        image_urls: [
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/4b98327ecb5144aca24a24ef5c12dc19~tplv-photomode-image\.jpeg\?},
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/5d150a6256c2495a9abaf46bef95718a~tplv-photomode-image\.jpeg\?},
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/609b8f14930e4a14ac34ba8abf0802e5~tplv-photomode-image\.jpeg\?},
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/bf31699b78984f308c02cabbf9476161~tplv-photomode-image\.jpeg\?},
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/08032c78a6d440a5a2506abb8cddee4f~tplv-photomode-image\.jpeg\?},
        ],
        media_files: [
          { file_size: 201_557 },
          { file_size: 125_252 },
          { file_size: 258_204 },
          { file_size: 150_041 },
          { file_size: 245_584 },
        ],
        page_url: "https://www.tiktok.com/@kasane_tetoee/photo/7684866893383077127",
        profile_url: "https://www.tiktok.com/@kasane_tetoee",
        profile_urls: %w[https://www.tiktok.com/@kasane_tetoee],
        display_name: "Kasane_tetoe",
        username: "kasane_tetoee",
        published_at: Time.parse("2026-09-13T04:08:34Z"),
        updated_at: nil,
        tags: [
          ["fyp", "https://www.tiktok.com/tag/fyp"],
          ["kasaneteto", "https://www.tiktok.com/tag/kasaneteto"],
          ["gearsofwar", "https://www.tiktok.com/tag/gearsofwar"],
          ["artist", "https://www.tiktok.com/tag/artist"],
        ],
        dtext_artist_commentary_title: "Gears of wars 2 x teto art by me",
        dtext_artist_commentary_desc: "This took me an extremely long time to draw #fyp #kasaneteto #gearsofwar #artist",
      )
    end

    context "A shortened share link" do
      strategy_should_work(
        "https://vt.tiktok.com/ZSa9V7ert/",
        image_urls: [
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/e60ec7487beb4d1fa35045d1fbac0005~tplv-photomode-image\.jpeg\?},
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/2ce2ee02f27d45d88b43f480a5382557~tplv-photomode-image\.jpeg\?},
          %r{\Ahttps://p\d+-common-sign\.tiktokcdn[a-z-]*\.com/tos-[\w-]+/4ea9bf093675453daf7d6c077abd3a40~tplv-photomode-image\.jpeg\?},
        ],
        media_files: [
          { file_size: 280_229 },
          { file_size: 138_335 },
          { file_size: 182_566 },
        ],
        page_url: "https://www.tiktok.com/@pyromannce/photo/7584709238878915858",
        profile_url: "https://www.tiktok.com/@pyromannce",
        profile_urls: %w[https://www.tiktok.com/@pyromannce],
        display_name: "☣ρуяσ☭🇲🇽",
        username: "pyromannce",
        published_at: Time.parse("2025-12-17T06:25:39Z"),
        updated_at: nil,
        tags: [
          ["manhunt2", "https://www.tiktok.com/tag/manhunt2"],
          ["manhunt", "https://www.tiktok.com/tag/manhunt"],
          ["leokasper", "https://www.tiktok.com/tag/leokasper"],
          ["daniellamb", "https://www.tiktok.com/tag/daniellamb"],
          ["rockstargames", "https://www.tiktok.com/tag/rockstargames"],
        ],
        dtext_artist_commentary_title: "Carpe diem, before it's too late.",
        dtext_artist_commentary_desc: "A friend mentioned that it looked better as an X-ray; actually, it gave it a special touch, and it fits better with what Manhunt 2 is all about. So far I must say that it is the drawing I have liked the most that I have done. #manhunt2 #Manhunt #LeoKasper #DanielLamb #rockstargames",
      )
    end

    context "A video post" do
      strategy_should_work(
        "https://www.tiktok.com/@ashshae0/video/7618903378113924373",
        image_urls: [%r{\Ahttps://v\d+-webapp-prime\.tiktok\.com/video/tos/[\w/-]+/\?.*&tk=tt_chain_token}],
        media_files: [{ file_size: 1_307_367 }],
        page_url: "https://www.tiktok.com/@ashshae0/video/7618903378113924373",
        profile_url: "https://www.tiktok.com/@ashshae0",
        profile_urls: %w[https://www.tiktok.com/@ashshae0],
        display_name: "Ashy",
        username: "ashshae0",
        published_at: Time.parse("2026-03-19T09:56:28Z"),
        updated_at: nil,
        tags: [
          ["sonamy", "https://www.tiktok.com/tag/sonamy"],
          ["amyrose", "https://www.tiktok.com/tag/amyrose"],
          ["somethingaboutamy", "https://www.tiktok.com/tag/somethingaboutamy"],
          ["sonicthehedgehog", "https://www.tiktok.com/tag/sonicthehedgehog"],
          ["fyp", "https://www.tiktok.com/tag/fyp"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "cr @ATTAY / something about Amy #sonamy #amyrose #somethingaboutamy #sonicthehedgehog #fyp",
      )
    end

    context "A video url with the post as the referer" do
      setup do
        @page_url = "https://www.tiktok.com/@ashshae0/video/7618903378113924373"
        # An old video URL whose tt_chain_token we don't have.
        @video_url = "https://v16-webapp-prime.tiktok.com/video/tos/alisg/tos-alisg-ve-0068c800-sg/oMAQ7FPCfdpFDyzCjfcC4WIeA4EBDWJEXTT4Ii/?a=1988&bti=ODszNWYuMDE6&&bt=981&mime_type=video_mp4&expire=1794761549&ply_type=2&policy=2&signature=4c62d7d23aec94c84d7e6b028d958588&tk=tt_chain_token&btag=e000b8000"
        @extractor = Source::Extractor.find(@video_url, @page_url)
      end

      should "download the video from a fresh page request" do
        assert_equal(1_307_367, @extractor.download_file!(@video_url).file_size)
        assert_equal([@video_url], @extractor.image_urls)
        assert_equal(@page_url, @extractor.page_url)
      end

      should "get a new token and retry if the download fails because the token doesn't work" do
        @extractor.item
        @extractor.http.http.default_options.features[:session].cookie_jar.parse("tt_chain_token=invalid; domain=.tiktok.com; path=/", "https://www.tiktok.com")

        assert_equal(1_307_367, @extractor.download_file!(@video_url).file_size)
      end

      should "not retry if the download fails with another error" do
        Danbooru::Http.any_instance.expects(:download_media).once.raises(download_error(404))

        assert_raises(Danbooru::Http::DownloadError) { @extractor.download_file!(@video_url) }
      end
    end

    context "A tiktokcdn image url" do
      strategy_should_work(
        "https://p16-common-sign.tiktokcdn-us.com/tos-useast5-i-photomode-tx/c997051aa88446328e44de163d83a30c~tplv-photomode-image.jpeg?dr=9616&x-expires=1774238400&x-signature=mnDyZBX35%2BTC4y8Uvno95%2FiewDU%3D&t=4d5b0474&ps=13740610&shp=81f88b70&shcp=9b759fb9&idc=useast5&ftpl=1",
        image_urls: %w[https://p16-common-sign.tiktokcdn-us.com/tos-useast5-i-photomode-tx/c997051aa88446328e44de163d83a30c~tplv-photomode-image.jpeg?dr=9616&x-expires=1774238400&x-signature=mnDyZBX35%2BTC4y8Uvno95%2FiewDU%3D&t=4d5b0474&ps=13740610&shp=81f88b70&shcp=9b759fb9&idc=useast5&ftpl=1],
        page_url: nil,
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted or nonexistent post" do
      strategy_should_work(
        "https://www.tiktok.com/@kasane_tetoee/photo/1",
        image_urls: [],
        page_url: "https://www.tiktok.com/@kasane_tetoee/photo/1",
        profile_url: "https://www.tiktok.com/@kasane_tetoee",
        profile_urls: %w[https://www.tiktok.com/@kasane_tetoee],
        display_name: nil,
        username: "kasane_tetoee",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    def download_error(status)
      response = HTTP::Response.new(status: status, version: "1.1", body: "", request: HTTP::Request.new(verb: :get, uri: "https://www.tiktok.com"))
      Danbooru::Http::DownloadError.new("failed with code #{status}", response: response)
    end
  end
end
