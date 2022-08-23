require "test_helper"

module Sources
  class DeviantArtTest < ActiveSupport::TestCase
    def setup
      super
      skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
    end

    context "A deviantart post" do
      strategy_should_work(
        "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/11a24395-0f24-446d-ae73-a9f812e79e55/d70rm0s-e5b6b5e6-5795-44bb-a0ba-27b5c2349be7\.jpg}],
        download_size: 877_987,
        page_url: "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484",
        artist_name: "aeror404",
        profile_url: "https://www.deviantart.com/aeror404",
        artist_commentary_title: "Holiday Elincia"
      )
    end

    context "A deviantart image" do
      strategy_should_work(
        "https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png",
        image_urls: ["https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png"],
        download_size: 840_296,
        page_url: "https://www.deviantart.com/nickbeja/art/Mindflayer-Girl01-708675884",
        artist_name: "nickbeja",
        profile_url: "https://www.deviantart.com/nickbeja"
      )
    end

    context "Another deviantart image" do
      strategy_should_work(
        "https://pre00.deviantart.net/b5e6/th/pre/f/2016/265/3/5/legend_of_galactic_heroes_by_hideyoshi-daihpha.jpg",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/b1f96af6-56a3-47a8-b7f4-406f243af3a3/daihpha-9f1fcd2e-7557-4db5-951b-9aedca9a3ae7\.jpg}],
        download_size: 906_621,
        page_url: "https://www.deviantart.com/hideyoshi/art/Legend-of-Galactic-Heroes-635721022",
        artist_name: "hideyoshi",
        profile_url: "https://www.deviantart.com/hideyoshi",
        tags: %w[barbarossa bay brunhild flare hangar odin planet ship spaceship sun sunset brünhild legendsofgalacticheroes]
      )
    end

    context "A deviantart post with the intermediary version giving 404" do
      strategy_should_work(
        "https://www.deviantart.com/gregmks/art/Rhino-Castle-811778248",
        image_urls: [%r{\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/8c03bd02-63bf-407e-9c3e-c3fd21ab4bd5/ddfb83s-64c3b1fd-a554-498c-87dd-7ce83721a3d0\.jpg\?token=}]
      )
    end

    context "A deviantart origin-orig image" do
      desc = <<-EOS.strip_heredoc.chomp
        blah blah
        "test link":[http://www.google.com]

        h1. lol



        [b]blah[/b] [i]blah[/i] [u]blah[/u] [s]blah[/s]
        herp derp

        [quote]this is a quote[/quote]

        * one
        * two
        * three

        * one
        * two
        * three

        "Heart":[https://e.deviantart.net/emoticons/h/heart.gif]
      EOS

      strategy_should_work(
        "http://origin-orig.deviantart.net/7b5b/f/2017/160/c/5/test_post_please_ignore_by_noizave-dbc3a48.png",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3a48-10b9e2e8-b176-4820-ab9e-23449c11e7c9\.png}],
        download_size: 3_619,
        page_url: "https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408",
        artist_name: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        tags: %w[bar baz foo],
        artist_commentary_title: "test post please ignore",
        dtext_artist_commentary_desc: desc
      )
    end

    context "A img00.deviantart.net sample" do
      strategy_should_work(
        "https://img00.deviantart.net/a233/i/2017/160/5/1/test_post_please_ignore_by_noizave-dbc3a48.png",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3a48-10b9e2e8-b176-4820-ab9e-23449c11e7c9\.png}],
        download_size: 3_619,
        page_url: "https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408"
      )
    end

    context "A th00.deviantart.net/*/PRE/* thumbnail" do
      strategy_should_work(
        "http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a\.png}],
        download_size: 3_391_584,
        page_url: "https://www.deviantart.com/xyelkiltrox/art/Goruto-438744629"
      )
    end

    context "A deviantart page with download disabled" do
      strategy_should_work(
        "https://noizave.deviantart.com/art/test-no-download-697415967",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbj81lr-3306feb1-87dc-4d25-9a4c-da8d2973a8b7\.jpg\?token=}],
        download_size: 59_401,
        page_url: "https://www.deviantart.com/noizave/art/test-no-download-697415967",
        artist_name: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        artist_commentary_title: "test, no download"
      )
    end

    context "A deviantart page with download disabled for a huge file" do
      strategy_should_work(
        "https://www.deviantart.com/anatofinnstark/art/The-Blade-of-Miquella-914166242",
        download_size: 26_037_561
      )
    end

    context "A deviantart page with download enabled" do
      strategy_should_work(
        "https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/a6289ca5-2205-4118-af55-c6934fba0930/dct67m5-51e8db38-9167-4f5c-931d-561ea4d3810d\.jpg}],
        download_size: 1_402_017,
        page_url: "https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781",
        artist_name: "len1",
        profile_url: "https://www.deviantart.com/len1",
        artist_commentary_title: "All that Glitters II"
      )
    end

    context "A *.deviantart.net/*/:title_by_:artist.jpg image with an artist name containing underscores" do
      strategy_should_work(
        "https://orig00.deviantart.net/4274/f/2010/230/8/a/pkmn_king_and_queen_by_mikoto_chan.jpg",
        image_urls: ["https://orig00.deviantart.net/4274/f/2010/230/8/a/pkmn_king_and_queen_by_mikoto_chan.jpg"],
        artist_name: "mikoto-chan",
        profile_url: "https://www.deviantart.com/mikoto-chan",
        page_url: nil
      )
    end

    context "A *.deviantart.net/*/:hash.jpg image without referer" do
      strategy_should_work(
        "http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg",
        image_urls: ["http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg"],
        profile_url: nil,
        page_url: nil
      )
    end

    context "A *.deviantart.net/*/:hash.jpg image with referer" do
      strategy_should_work(
        "http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg",
        referer: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",
        image_urls: [%r{\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg}],
        artist_name: "edsfox",
        profile_url: "https://www.deviantart.com/edsfox",
        page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896"
      )
    end

    context "A images-wixmp-.* sample" do
      strategy_should_work(
        "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
        referer: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",
        image_urls: [%r{\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg}],
        artist_name: "edsfox",
        profile_url: "https://www.deviantart.com/edsfox",
        page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896"
      )
    end

    context "A api-da.wixmp.com sample" do
      strategy_should_work(
        "https://api-da.wixmp.com/_api/download/file?downloadToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q",
        referer: "https://www.deviantart.com/akizero1510/art/Ten-miles-of-cherry-blossoms-792268029",
        page_url: "https://www.deviantart.com/akizero1510/art/Ten-miles-of-cherry-blossoms-792268029"
      )
    end

    context "A non-downloadable animated gif with id<=790677560" do
      strategy_should_work(
        "https://www.deviantart.com/heartgear/art/Silent-Night-579982816",
        image_urls: [%r{\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/ea95be00-c5aa-4063-bd55-f5a9183912f7/d9lb1ls-7d625444-0003-4123-bf00-274737ca7fdd.gif\?token=}],
        download_size: 350_156
      )
    end

    context "A non-downloadable video file" do
      strategy_should_work(
        "https://www.deviantart.com/gs-mantis/art/Chen-Goes-Fishing-505847233",
        image_urls: ["https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/fe046bc7-4d68-4699-96c1-19aa464edff6/d8d6281-91959e92-214f-4b2d-a138-ace09f4b6d09.1080p.8e57939eba634743a9fa41185e398d00.mp4"],
        download_size: 9_739_947
      )
    end

    context "A login-only deviantart post" do
      strategy_should_work(
        "http://noizave.deviantart.com/art/hidden-work-685458369",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3r29-10c99118-5cfe-4402-ad55-7b57e7c0ca43\.png}],
        download_size: 3_619
      )
    end

    context "A source with malformed links in the artist commentary" do
      should "fix the links" do
        @site = Source::Extractor.find("https://www.deviantart.com/dishwasher1910/art/Solar-Sisters-792488305")

        assert_equal(<<~EOS.chomp, @site.dtext_artist_commentary_desc)
          Solar sisters 

          HD images , Psd file and alternative version available on my Patreon :
          "www.patreon.com/Dishwasher1910":[https://www.patreon.com/Dishwasher1910]
          You can buy the print here :
          "www.inprnt.com/gallery/dishwas…":[https://www.inprnt.com/gallery/dishwasher1910/solar-sisters/]
        EOS
      end
    end

    context "An artist entry with a profile url that is missing the 'www'" do
      should "still find the artist" do
        @site = Source::Extractor.find("http://noizave.deviantart.com/art/test-post-please-ignore-685436408")
        @artist = create(:artist, name: "noizave", url_string: "https://deviantart.com/noizave")

        assert_equal([@artist], @site.artists)
      end
    end

    should "Parse DeviantArt URLs correctly" do
      source1 = "http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg"
      source2 = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg"
      source3 = "http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png"
      source4 = "http://fc00.deviantart.net/fs71/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg"
      source5 = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc"
      source6 = "https://fav.me/dbc3a48"

      assert(Source::URL.image_url?(source1))
      assert(Source::URL.image_url?(source2))
      assert(Source::URL.image_url?(source3))
      assert(Source::URL.image_url?(source4))
      assert(Source::URL.image_url?(source5))
      assert(Source::URL.page_url?(source6))

      assert_equal("https://www.deviantart.com/mar11co/art/You-Are-Already-Dead-408921710", Source::URL.page_url(source1))
      assert_equal("https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896", Source::URL.page_url(source2))
      assert_equal("https://www.deviantart.com/melisaongmiqin/art/Illustration-Tokyo-Encount-Oei-659256076", Source::URL.page_url(source3))
      assert_equal("https://www.deviantart.com/deviation/417560500", Source::URL.page_url(source4))
      assert_equal("https://www.deviantart.com/deviation/599977532", Source::URL.page_url(source5))
      assert_equal("https://www.deviantart.com/deviation/685436408", Source::URL.page_url(source6))

      assert(Source::URL.image_url?("http://www.deviantart.com/download/135944599/Touhou___Suwako_Moriya_Colored_by_Turtle_Chibi.png"))
      assert(Source::URL.image_url?("http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg"))
      assert(Source::URL.image_url?("http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg"))
      assert(Source::URL.page_url?("https://sta.sh/0wxs31o7nn2"))
      assert(Source::URL.profile_url?("https://www.deviantart.com/noizave"))
      assert(Source::URL.profile_url?("https://noizave.deviantart.com"))
      assert_not(Source::URL.profile_url?("https://deviantart.net"))
    end
  end
end
