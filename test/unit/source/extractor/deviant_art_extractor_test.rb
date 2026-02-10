require "test_helper"

module Source::Tests::Extractor
  class DeviantArtExtractorTest < ActiveSupport::ExtractorTestCase
    setup do
      skip "DeviantArt API keys not set" unless Source::Extractor::DeviantArt.enabled?
    end

    context "A deviantart post" do
      strategy_should_work(
        "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484",
        image_urls: [%r{https://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/11a24395-0f24-446d-ae73-a9f812e79e55/d70rm0s-e5b6b5e6-5795-44bb-a0ba-27b5c2349be7\.jpg\?token=}],
        media_files: [{ file_size: 877_987, width: 1620, height: 1380 }],
        page_url: "https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484",
        display_name: "aeror404",
        username: "aeror404",
        profile_url: "https://www.deviantart.com/aeror404",
        published_at: Time.parse("2014-01-04T08:56:39.000000Z"),
        updated_at: nil,
        tags: [],
        artist_commentary_title: "Holiday Elincia",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Christmas sketch commission! Elincia from Fire Emblem! Thanks!
          I think it suits her really well. * - * Also you can never go wrong with sexy Christmas sweaters!
        EOS
      )
    end

    context "An old deviantart image for a deleted post" do
      strategy_should_work(
        "https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png",
        image_urls: ["https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/76184f5d-6a6f-4410-aba9-e8b672c22b80/dbpxdt8-20d2d385-4d92-4314-bafc-46a1310752fd.png"],
        media_files: [{ file_size: 1_740_425, width: 1093, height: 3331 }],
        page_url: "https://www.deviantart.com/nickbeja/art/Mindflayer-Girl01-708675884",
        display_name: nil,
        username: "nickbeja",
        profile_url: "https://www.deviantart.com/nickbeja",
        published_at: nil,
        updated_at: nil,
        tags: [],
        artist_commentary_title: nil, # XXX use filename?
        artist_commentary_desc: nil,
      )
    end

    context "An old downloadable deviantart image" do
      strategy_should_work(
        "https://pre00.deviantart.net/b5e6/th/pre/f/2016/265/3/5/legend_of_galactic_heroes_by_hideyoshi-daihpha.jpg",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/b1f96af6-56a3-47a8-b7f4-406f243af3a3/daihpha-9f1fcd2e-7557-4db5-951b-9aedca9a3ae7\.jpg\?token=.+&filename=legend_of_galactic_heroes_by_hideyoshi_daihpha\.jpg}],
        media_files: [{ file_size: 906_621, width: 1600, height: 1044 }],
        page_url: "https://www.deviantart.com/hideyoshi/art/Legend-of-Galactic-Heroes-635721022",
        display_name: "Hideyoshi",
        username: "hideyoshi",
        profile_url: "https://www.deviantart.com/hideyoshi",
        published_at: nil,
        updated_at: nil,
        tags: %w[barbarossa bay brunhild flare hangar odin planet ship spaceship sun sunset brünhild legendsofgalacticheroes],
        artist_commentary_title: "Legend of Galactic Heroes",
        dtext_artist_commentary_desc: "Shamefully I have to say I didn't know this anime show before. wat? o_O Yet was approached to create a commissioned piece.. This is the result - Barbarossa and Brunhild landing on Odin.",
      )
    end

    context "A deviantart post without a downloadable or /intermediary/ image" do
      strategy_should_work(
        "https://www.deviantart.com/gregmks/art/Rhino-Castle-811778248",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/8c03bd02-63bf-407e-9c3e-c3fd21ab4bd5/ddfb83s-64c3b1fd-a554-498c-87dd-7ce83721a3d0\.jpg\?token=.+&filename=rhino_castle_by_gregmks_ddfb83s\.jpg}],
        media_files: [{ size: 662_982, width: 1200, height: 1500 }],
        page_url: "https://www.deviantart.com/gregmks/art/Rhino-Castle-811778248",
        display_name: "gregmks",
        username: "gregmks",
        profile_url: "https://www.deviantart.com/gregmks",
        published_at: Time.parse("2019-09-01T17:06:05.000000Z"),
        updated_at: nil,
        tags: [],
        artist_commentary_title: "Rhino Castle",
        dtext_artist_commentary_desc: 'Started as a simple Rhino sketch and it escalated quickly ":P (Lick)":[https://e.deviantart.net/emoticons/letters/=p.gif]',
      )
    end

    context "A downloadable deviantart origin-orig image" do
      strategy_should_work(
        "http://origin-orig.deviantart.net/7b5b/f/2017/160/c/5/test_post_please_ignore_by_noizave-dbc3a48.png",
        image_urls: [%r{https://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3a48-10b9e2e8-b176-4820-ab9e-23449c11e7c9\.png\?token=}],
        media_files: [{ file_size: 3_619, width: 1152, height: 648 }],
        page_url: "https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408",
        display_name: "noizave",
        username: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        published_at: nil,
        updated_at: nil,
        tags: %w[bar baz foo],
        artist_commentary_title: "test post please ignore",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          blah blah
          "test link":[http://www.google.com]

          h1. lol

          [b]blah[/b] [i]blah[/i] [u]blah[/u] [s]blah[/s]
          herp derp

          [quote]
          this is a quote
          [/quote]

          * one
          * two
          * three

          * one
          * two
          * three

          ":Heart:":[https://e.deviantart.net/emoticons/h/heart.gif]
        EOS
      )
    end

    context "A img00.deviantart.net sample" do
      strategy_should_work(
        "https://img00.deviantart.net/a233/i/2017/160/5/1/test_post_please_ignore_by_noizave-dbc3a48.png",
        image_urls: [%r{https://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3a48-10b9e2e8-b176-4820-ab9e-23449c11e7c9\.png\?token=}],
        media_files: [{ file_size: 3_619, width: 1152, height: 648 }],
        page_url: "https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408",
        published_at: nil,
        updated_at: nil,
      )
    end

    context "A th00.deviantart.net/*/PRE/* thumbnail" do
      strategy_should_work(
        "http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/d8995973-0b32-4a7d-8cd8-d847d083689a/d797tit-1eac22e0-38b6-4eae-adcb-1b72843fd62a\.png\?token=.+&filename=goruto_by_xyelkiltrox_d797tit\.png}],
        media_files: [{ file_size: 3_391_584, width: 2078, height: 3201 }],
        page_url: "https://www.deviantart.com/xyelkiltrox/art/Goruto-438744629",
        display_name: "XYelkiltroX",
        username: "xyelkiltrox",
        profile_url: "https://www.deviantart.com/xyelkiltrox",
        published_at: nil,
        updated_at: nil,
        tags: [],
        artist_commentary_title: "Goruto",
        dtext_artist_commentary_desc: "Fusión de Goku y Naruto al estilo de Akira Toriyama",
      )
    end

    context "A deviantart page with download disabled" do
      strategy_should_work(
        "https://noizave.deviantart.com/art/test-no-download-697415967",
        image_urls: ["https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbj81lr-3306feb1-87dc-4d25-9a4c-da8d2973a8b7.jpg"],
        media_files: [{ file_size: 40_036, width: 500, height: 500 }],
        page_url: "https://www.deviantart.com/noizave/art/test-no-download-697415967",
        display_name: "noizave",
        username: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        published_at: Time.parse("2017-08-07T21:17:27.000000Z"),
        updated_at: nil,
        tags: [],
        artist_commentary_title: "test, no download",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deviantart page with download disabled for a huge file" do
      strategy_should_work(
        "https://www.deviantart.com/anatofinnstark/art/The-Blade-of-Miquella-914166242",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/3d079e1f-386b-4bd0-84fc-cce9913fbc0c/df49r6q-b19fcb03-8c2e-4638-8c12-98d443c7ee33\.jpg/v1/fill/w_900,h_507/the_blade_of_miquella_by_anatofinnstark_df49r6q\.jpg\?token=}],
        media_files: [{ file_size: 155_461, width: 900, height: 507 }],
        page_url: "https://www.deviantart.com/anatofinnstark/art/The-Blade-of-Miquella-914166242",
        display_name: "AnatoFinnstark",
        username: "anatofinnstark",
        profile_url: "https://www.deviantart.com/anatofinnstark",
        published_at: Time.parse("2022-04-25T17:02:26.000000Z"),
        updated_at: nil,
        tags: [],
        artist_commentary_title: "The Blade of Miquella",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Another Malenia Art, and not the last ":) (Smile)":[https://e.deviantart.net/emoticons/s/smile.gif]

          Limited Print : "finnstarkillustration.com/blad…":[https://finnstarkillustration.com/blade-of-miquella-moon-only-20-copies-worldwide.html]
          Common print : "www.redbubble.com/fr/shop/ap/1…":[https://www.redbubble.com/fr/shop/ap/109026235?ref=studio-promote]
          Displate : "displate.com/anatofinnstark/el…":[https://displate.com/anatofinnstark/eldensouls?art=5eec73f09ab12]
        EOS
      )
    end

    context "A deviantart page with download enabled" do
      strategy_should_work(
        "https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/a6289ca5-2205-4118-af55-c6934fba0930/dct67m5-51e8db38-9167-4f5c-931d-561ea4d3810d\.jpg}],
        media_files: [{ file_size: 1_402_017, width: 1920, height: 1080 }],
        page_url: "https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781",
        display_name: "Len1",
        username: "len1",
        profile_url: "https://www.deviantart.com/len1",
        published_at: Time.parse("2018-11-29T14:21:35.000000Z"),
        updated_at: nil,
        artist_commentary_title: "All that Glitters II",
      )
    end

    context "A *.deviantart.net/*/:title_by_:artist.jpg image with an artist name containing underscores" do
      strategy_should_work(
        "https://orig00.deviantart.net/4274/f/2010/230/8/a/pkmn_king_and_queen_by_mikoto_chan.jpg",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/654817c0-5ba7-4591-9fd7-badae289cf88/d2wq7wl-b7f18546-753e-4d53-8051-ddb1879776c2\.jpg\?token=.+&filename=pkmn_king_and_queen_by_mikotoazure_d2wq7wl\.jpg}],
        media_files: [{ size: 401_175, width: 700, height: 543 }],
        page_url: "https://www.deviantart.com/mikotoazure/art/PKMN-King-and-Queen-175903365",
        display_name: "MikotoAzure",
        username: "mikotoazure",
        profile_url: "https://www.deviantart.com/mikotoazure",
        published_at: nil,
        updated_at: nil,
        tags: [],
        artist_commentary_title: "PKMN-King and Queen",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Commision for "wolfathegoddess2010":[https://wolfathegoddess2010.deviantart.com/]

          Reference:
          Nidoran♂ (King) > "[link]":[https://wolfathegoddess2010.deviantart.com/art/King-and-Anna-pokemon-173524307?q=gallery%3Awolfathegoddess2010%2F11255073&qo=10]
          Nidoran♀ (Queen) > "[link]":[https://wolfathegoddess2010.deviantart.com/art/Aoiro-and-Queen-175776997?q=gallery%3Awolfathegoddess2010%2F11255073&qo=0]

          Nidoran ♂ and ♀(c) Pokemon
          Art (c) Mikoto-chan
        EOS
      )
    end

    context "A *.deviantart.net/*/:hash.jpg image without referer" do
      strategy_should_work(
        "http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4\.jpg\?token=.+&filename=silverhawks_quicksilver_by_edsfox_d23jbr4\.jpg}],
        media_files: [{ file_size: 390_108, width: 791, height: 1_024 }],
        page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",
        display_name: "edsfox",
        username: "edsfox",
        profile_url: "https://www.deviantart.com/edsfox",
        published_at: nil,
        updated_at: nil,
        artist_commentary_title: "Silverhawks Quicksilver",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          First of all.. I love this cartoon from the 80's.. so I decide to make this Fan art of Quicksilver flying into the earth's sky..

          I decided this way cuz I was experimenting with the cloud brush XD hahaha.. so pardon me if you expect him surrounded by space and stars.. I know I know.. but.. well I think it looked cool at the end..

          Photoshop CS3, intuos3, few hours, reference on the character by SilverHawks cartoon series..

          SilverHawks belongs to WarnerBros.

          EDS
        EOS
      )
    end

    context "A *.deviantart.net/*/:hash.jpg image" do
      strategy_should_work(
        "http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4\.jpg\?token=.+&filename=silverhawks_quicksilver_by_edsfox_d23jbr4\.jpg}],
        media_files: [{ file_size: 390_108, width: 791, height: 1_024 }],
        page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",
        display_name: "edsfox",
        username: "edsfox",
        profile_url: "https://www.deviantart.com/edsfox",
        published_at: nil,
        updated_at: nil,
        artist_commentary_title: "Silverhawks Quicksilver",
      )
    end

    context "A images-wixmp-.* /intermediary/ sample" do
      strategy_should_work(
        "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4\.jpg\?token=.+&filename=silverhawks_quicksilver_by_edsfox_d23jbr4\.jpg}],
        media_files: [{ file_size: 390_108, width: 791, height: 1_024 }],
        page_url: "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896",
        display_name: "edsfox",
        username: "edsfox",
        profile_url: "https://www.deviantart.com/edsfox",
        published_at: nil,
        updated_at: nil,
        artist_commentary_title: "Silverhawks Quicksilver",
      )
    end

    context "A api-da.wixmp.com sample" do
      strategy_should_work(
        "https://api-da.wixmp.com/_api/download/file?downloadToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/e46a48eb-3d0b-449e-90dc-0a1b31cb1361/dd3p1x9-fb47bc8f-653e-42a2-bb4d-afaf9fc2b781\.jpg\?token=.+&filename=ten_miles_of_cherry_blossoms_by_akizero1510_dd3p1x9\.jpg}],
        media_files: [{ size: 1_289_162, width: 1415, height: 1000 }],
        page_url: "https://www.deviantart.com/akizero1510/art/Ten-miles-of-cherry-blossoms-792268029",
        display_name: "AkiZero1510",
        username: "akizero1510",
        profile_url: "https://www.deviantart.com/akizero1510",
        published_at: nil,
        updated_at: nil,
        tags: [],
        artist_commentary_title: "Ten miles of cherry blossoms",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Commission for "shrimpHEBY":[https://www.deviantart.com/shrimpheby]
          Hope you guys enjoy! (｢･ω･)｢
        EOS
      )
    end

    context "A non-downloadable animated gif with id<=790677560" do
      strategy_should_work(
        "https://www.deviantart.com/heartgear/art/Silent-Night-579982816",
        image_urls: [%r{\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/ea95be00-c5aa-4063-bd55-f5a9183912f7/d9lb1ls-7d625444-0003-4123-bf00-274737ca7fdd\.gif\?token=}],
        media_files: [{ file_size: 350_156, width: 746, height: 977 }],
        published_at: Time.parse("2015-12-24T18:19:04.000000Z"),
        updated_at: nil,
      )
    end

    context "A page containing a non-downloadable video file" do
      strategy_should_work(
        "https://www.deviantart.com/cutenikechan/art/Amelia-900276912",
        image_urls: %w[https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/d204f74b-728d-4a3e-9d85-217e5f4fffa3/dew0240-8051caf7-f08a-4727-a974-7f5396644c2a.VideoQualities.res_1080p.23d4baf83a244c979bc3378b2643dfb6.mp4],
        media_files: [{ file_size: 13_369_722, width: 1920, height: 1080 }],
        page_url: "https://www.deviantart.com/cutenikechan/art/Amelia-900276912",
        profile_url: "https://www.deviantart.com/cutenikechan",
        profile_urls: %w[https://www.deviantart.com/cutenikechan],
        display_name: "CuteNikeChan",
        username: "cutenikechan",
        other_names: ["CuteNikeChan"],
        published_at: Time.parse("2021-12-10T17:46:49.000000Z"),
        updated_at: nil,
        tags: [
          ["chakraguardians", "https://www.deviantart.com/tag/chakraguardians"],
          ["animation", "https://www.deviantart.com/tag/animation"],
        ],
        dtext_artist_commentary_title: "Amelia",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          my baby 💙💙💙
          i finally finished this! gave myself a week and ended up taking 3 months LOL 💦
          thanks for all the support! <3

          available on youtube: "youtu.be/q_ZvkSLZL8Y":[https://youtu.be/q_ZvkSLZL8Y]
          ♫ : damper – deeper (ft. cookie) - "youtu.be/38gqxMmNo7Q":[https://youtu.be/38gqxMmNo7Q]

          (c) chakra guardians
        EOS
      )
    end

    context "A direct non-downloadable video file" do
      strategy_should_work(
        "https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/d204f74b-728d-4a3e-9d85-217e5f4fffa3/dew0240-8051caf7-f08a-4727-a974-7f5396644c2a.VideoQualities.res_1080p.23d4baf83a244c979bc3378b2643dfb6.mp4",
        image_urls: %w[https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/d204f74b-728d-4a3e-9d85-217e5f4fffa3/dew0240-8051caf7-f08a-4727-a974-7f5396644c2a.VideoQualities.res_1080p.23d4baf83a244c979bc3378b2643dfb6.mp4],
        media_files: [{ file_size: 13_369_722, width: 1920, height: 1080 }],
        page_url: "https://www.deviantart.com/cutenikechan/art/Amelia-900276912",
        published_at: nil,
        updated_at: nil,
      )
    end

    context "A login-only deviantart post" do
      strategy_should_work(
        "http://noizave.deviantart.com/art/hidden-work-685458369",
        image_urls: [%r{\Ahttps://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3r29-10c99118-5cfe-4402-ad55-7b57e7c0ca43\.png}],
        media_files: [{ file_size: 3_619, width: 1152, height: 648 }],
        page_url: "https://www.deviantart.com/noizave/art/hidden-work-685458369",
        display_name: "noizave",
        username: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        published_at: Time.parse("2017-06-09T17:08:44.000000Z"),
        updated_at: nil,
        tags: %w[bar baz foo],
        artist_commentary_title: "hidden work",
      )
    end

    context "A subscribers-only DeviantArt image" do
      strategy_should_work(
        "https://www.deviantart.com/bnjacob/art/Celestial-Muse-1-1007346855",
        image_urls: [],
        media_files: [],
        page_url: "https://www.deviantart.com/bnjacob/art/Celestial-Muse-1-1007346855",
        profile_url: "https://www.deviantart.com/bnjacob",
        display_name: "BNJacob",
        username: "bnjacob",
        other_names: ["BNJacob"],
        published_at: Time.parse("2024-01-02T10:59:53.000000Z"),
        updated_at: nil,
        dtext_artist_commentary_title: "Celestial Muse #1",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          [i][b]*Purchase by points on DeviantArt could help reduce the fee on me*
          [/b][u]
          P[/u][/i][u][i]urchase to download high quality image with no address watermark and support me in practically way.[/i]
          [i]Ratio: 16:9[/i][/u][b]

          Censored preview:

          [/b][i][b]Support my work and access all of my images at best quality on Patreon:
          "www.patreon.com/BNJacob":[https://www.patreon.com/BNJacob]

          [/b][/i][b]This image on Patreon:
          "www.patreon.com/posts/95711276":[https://www.patreon.com/posts/95711276][/b]"Follow me on other sites":[https://linktr.ee/726sHSArt]
        EOS
      )
    end

    context "A watchers-only DeviantArt image" do
      setup do
        skip "Deleted post"
      end

      strategy_should_work(
        "https://www.deviantart.com/theraceai/art/Realistic-Girl-14-1027403734",
        image_urls: [],
        page_url: "https://www.deviantart.com/theraceai/art/Ling-1027403734",
        profile_urls: %w[https://www.deviantart.com/theraceai],
        display_name: "TheraceAI",
        username: "theraceai",
        tags: [
          ["3d", "https://www.deviantart.com/tag/3d"],
          ["adventure", "https://www.deviantart.com/tag/adventure"],
          ["anime", "https://www.deviantart.com/tag/anime"],
          ["beauty", "https://www.deviantart.com/tag/beauty"],
          ["cartoon", "https://www.deviantart.com/tag/cartoon"],
          ["characterdesign", "https://www.deviantart.com/tag/characterdesign"],
          ["comics", "https://www.deviantart.com/tag/comics"],
          ["digitalart", "https://www.deviantart.com/tag/digitalart"],
          ["drama", "https://www.deviantart.com/tag/drama"],
          ["fanart", "https://www.deviantart.com/tag/fanart"],
          ["fantasy", "https://www.deviantart.com/tag/fantasy"],
          ["fashion", "https://www.deviantart.com/tag/fashion"],
          ["glitchart", "https://www.deviantart.com/tag/glitchart"],
          ["horror", "https://www.deviantart.com/tag/horror"],
          ["illustration", "https://www.deviantart.com/tag/illustration"],
          ["landscape", "https://www.deviantart.com/tag/landscape"],
          ["manga", "https://www.deviantart.com/tag/manga"],
          ["music", "https://www.deviantart.com/tag/music"],
          ["mystery", "https://www.deviantart.com/tag/mystery"],
          ["nature", "https://www.deviantart.com/tag/nature"],
          ["oilpainting", "https://www.deviantart.com/tag/oilpainting"],
          ["photography", "https://www.deviantart.com/tag/photography"],
          ["pixelart", "https://www.deviantart.com/tag/pixelart"],
          ["portrait", "https://www.deviantart.com/tag/portrait"],
          ["romance", "https://www.deviantart.com/tag/romance"],
          ["scifi", "https://www.deviantart.com/tag/scifi"],
          ["traditionalart", "https://www.deviantart.com/tag/traditionalart"],
          ["videogamefanart", "https://www.deviantart.com/tag/videogamefanart"],
          ["wallpapers", "https://www.deviantart.com/tag/wallpapers"],
          ["aiartcommunity", "https://www.deviantart.com/tag/aiartcommunity"],
          ["ai-generated", "https://www.deviantart.com/tag/ai"],
        ],
        dtext_artist_commentary_title: "Ling",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          - For Exclusives & Adoptables

          ✅ You become the only Owner, after purchase.

          ✅ No Watermark after purchase.

          ✅ Free to do as you please with your new Art, after purchase.

          ✅ HD resolution.

          -----

          😎 Become the Owner of my Exclusive Arts/ Adoptables:

          <https://www.deviantart.com/theraceai/shop/exclusives>

          🔥 Check out my Hot NSFW Premium Galleries:

          <https://www.deviantart.com/theraceai/shop/premium_folders>

          😈🔥 Subscribe to 18+ NSFW content here:

          <https://www.deviantart.com/theraceai/subscriptions>

          😋 Give me Commissions or Requests (Let me Serve you, daddy):

          <https://www.deviantart.com/theraceai/shop/commissions>

          🏞️ Get 4K HD Wallpapers here:

          <https://www.deviantart.com/theraceai/gallery/91506132/wallpapers-for-pc-and-mobile>

          🤓 Learn how to make High-fidelity Art in just 7 days:

          <https://www.deviantart.com/theraceai/commission/I-Teach-you-everything-My-Secret-AI-Formulas-1691785>

          --------------------------------------------------------------------

          --------------------------------------------------------------------

          BUY MY MERCH 🍵👕🏜️📗🖊️

          Get the Physical Art version shipped to you, anywhere in the world.

          For DeviantArt, we print all our 4K HD wallpapers, Extremely Cute animals, Graveyard & Waifus Art into a wide variety of products for you.

          Get it from Teepublic:

          "www.teepublic.com/user/theraceai":[https://www.teepublic.com/user/theraceai]

          Get it from ThreadlessArtistShops (Recommended):

          "theraceai.threadless.com":[https://theraceai.threadless.com]

          Get it from FineArtAmerica (Collab):

          "www.fineartamerica.com/profiles/1-paul-omoregie":[https://www.fineartamerica.com/profiles/1-paul-omoregie]

          Each Store offers different types of products showcasing our art e.g Stickers, posters, phone cases, desk mats, notebooks etc.

          So, browse🔎 through all Merch stores to see which one you prefer.

          --------------------------------------------------------------------

          --------------------------------------------------------------------

          CHECK OUT OUR OTHER CREATIONS

          We create stuff on other platforms too, you know 🤠...Like Comics, Books, 3D Assets, Movies, Music, Apps, Games, YouTube & Freelancing platforms.

          Check them out:

          "www.linktr.ee/TheraceAI":[https://www.linktr.ee/TheraceAI]

          --------------------------------------------------------------------

          --------------------------------------------------------------------

          FOLLOW US ON SOCIAL MEDIA

          Stay up-to-date on any new stuff we create, both on DeviantArt & beyond.

          Instagram: "www.instagram.com/theraceai":[https://www.instagram.com/theraceai]

          Twitter: "www.twitter.com/@theraceai":[https://www.twitter.com/@theraceai]

          TikTok: "www.tiktok.com/@theraceai":[https://www.tiktok.com/@theraceai]
        EOS
      )
    end

    context "A source with malformed links in the artist commentary" do
      strategy_should_work(
        "https://www.deviantart.com/dishwasher1910/art/Solar-Sisters-792488305",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Solar sisters

          HD images , Psd file and alternative version available on my Patreon :
          "www.patreon.com/Dishwasher1910":[https://www.patreon.com/Dishwasher1910]
          You can buy the print here :
          "www.inprnt.com/gallery/dishwas…":[https://www.inprnt.com/gallery/dishwasher1910/solar-sisters/]
        EOS
      )
    end

    context "An artistname.deviantart.com page url" do
      strategy_should_work(
        "http://noizave.deviantart.com/art/test-post-please-ignore-685436408",
        image_urls: [%r{https://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbc3a48-10b9e2e8-b176-4820-ab9e-23449c11e7c9\.png\?token=}],
        page_url: "https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408",
        display_name: "noizave",
        username: "noizave",
        profile_url: "https://www.deviantart.com/noizave",
        published_at: Time.parse("2017-06-09T14:42:34.000000Z"),
        updated_at: nil,
        tags: %w[bar baz foo],
        artist_commentary_title: "test post please ignore",
      )
    end

    context "A deviantart page for a Flash file" do
      strategy_should_work(
        "https://www.deviantart.com/midorynn/art/NieR-Automata-Anime-703917761",
        image_urls: [%r{https://wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/e1d5122b-6fee-44df-8b8f-e6e8daa3396d/dbn3ef5-9e051a71-251d-4e0f-b5f1-3beb5e6a8667\.swf\?token=}],
        media_files: [{ size: 4_243_457, width: 700, height: 300 }],
        display_name: "midorynn",
        username: "midorynn",
        profile_url: "https://www.deviantart.com/midorynn",
        published_at: Time.parse("2017-09-12T20:22:39.000000Z"),
        updated_at: nil,
        tags: %w[animation fanart nier_automata nierautomata nier_automata_2b],
        artist_commentary_title: "NieR: Automata Anime",
      )
    end

    context "An AI-generated DeviantArt post" do
      strategy_should_work(
        "https://www.deviantart.com/izzyrozenberg/art/Makima-looks-back-1-1027063213",
        tags: %w[anime animegirl cartoon cuteanimegirl drama fanart manga nude oilpainting redhead makimachainsawman makima_chainsaw_man eyesbeautiful makima ai-generated],
      )
    end

    context "A DeviantArt post with deeply nested commentary" do
      strategy_should_work(
        "https://www.deviantart.com/sakimichan/art/Tifa-Pullup-pinup-841327466",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          [b]"Pixiv ":[https://www.pixiv.net/member.php?id=3384404]ll"facebook ":[https://www.facebook.com/Sakimichanart/] [/b]ll"Online Store":[https://sakimichanart.storenvy.com/] ll "Tumblr":[https://sakimichan.tumblr.com/] ll [b]"Patreon":[https://www.patreon.com/sakimichan][/b]ll[b]"Artstation":[https://www.artstation.com/artist/sakimichan][/b]l[b]"Instagram":[https://instagram.com/sakimi.chan/][/b] [b]"gumroad(tutorial store)":[https://gumroad.com/sakimichan][/b] [b]cubebrush"(new tutorial store)":[https://cubebrush.co/sakimichan][/b]

          Tifa is my favorite female character in the final fantasy series ! Also the pull boss was one of my favorite section of the game so i wanted to try painting her doing some (struggled to paint out this idea)^u^~

          * High res jpg steps
          * layer PSD
          * video process

          h4. ❅"available on patreon ":[https://www.patreon.com/posts/36972487]

          " Patreon reward archive ":[https://sakimichan.deviantart.com/journal/Patreon-Rewards-Archive-498302321]( see what rewards you can get by helping support me !)

          FREE RELEASE! Enjoy ^_^

          ____________________
          Hair voice over tutorial
          please go: "gumroad.com/l/ojqB":[https://gumroad.com/l/ojqB]
          used the promo code: hairy ( unlimited )

          more tutorials here :"gumroad.com/sakimichan":[https://gumroad.com/sakimichan#] if you guys are interested !                                    "www.patreon.com/posts/18431891":[https://www.patreon.com/posts/18431891]
        EOS
      )
    end

    context "A DeviantArt post with <sub> tags in the commentary" do
      strategy_should_work(
        "https://www.deviantart.com/hoshi-pan/art/Speedpaint-Dolphins-And-Lemon-Juice-700265840",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h1. SPEEDPAINT: "www.youtube.com/watch?v=M72Kg9…":[https://www.youtube.com/watch?v=M72Kg9KhPQc]

          [s]Coughs random title for the win[/s]

          I haven't drawn something original in a while this was so much fun!! At first I wasn't going to add a BG but then I realized how hard it is for me not to add a bg xD [s]bc if I don't I feel like I'm lazy and a failure//slapped[/s].It was fun painting the sky and water,though I have a lot to improve on >q</

          Hope you like it! Speedpaint will be up soon "luvluvplz":[https://luvluvplz.deviantart.com/] !

          ________________________________________________________

          [b]CM info | "fav.me/dbaalkv":[http://fav.me/dbaalkv][/b]
        EOS
      )
    end

    context "A DeviantPost with a commentary created using the WYSIWYG text editor" do
      strategy_should_work(
        "https://www.deviantart.com/noizave/art/1-Image-No-Contribution-1048220942",
        image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dhc30ge-d2c07e30-3914-479d-8098-72ad01dc1209\.jpg\?token=.+&filename=_1_image_no_contribution_by_noizave_dhc30ge\.jpg}],
        media_files: [{ file_size: 213_868 }],
        page_url: "https://www.deviantart.com/noizave/art/1-Image-No-Contribution-1048220942",
        profile_url: "https://www.deviantart.com/noizave",
        profile_urls: %w[https://www.deviantart.com/noizave],
        display_name: "noizave",
        username: "noizave",
        other_names: ["noizave"],
        published_at: Time.parse("2024-05-03T04:52:56.000000Z"),
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "-1 Image No Contribution",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h2. title

          test 😀 [b]bold[/b] [i]italic[/i] [u]underline[/u] [b]abc[/b][b][i]def[/i][/b][b]gh[/b][b][i][u]ijk[/u][/i][/b][b]lmn[/b] "asdf":[http://google.com] asf

          [quote]
          quote
          [/quote]

          * list one

          * list two

          centered

          right

          justified

          ":hemolami:":[https://www.deviantart.com/hemolami] asdf

          <https://www.youtube.com/embed/dQw4w9WgXcQ>

          <https://www.deviantart.com/noizave/art/test-no-download-697415967>

          * "[image]":[http://google.com]
          * "[image]":[https://www.deviantart.com/noizave/art/Untitled-2-691140743]
          * "[image]":[https://www.deviantart.com/noizave/art/hidden-work-685458369]
          * "[image]":[https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408]

          "[image]":[https://media3.giphy.com/media/DDr3u60PjEFlWlitei/giphy.gif]
        EOS
      )
    end

    context "For Sta.sh:" do
      context "A https://sta.sh/:id url" do
        strategy_should_work(
          "https://sta.sh/0wxs31o7nn2",
          image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6\.png\?token=.+&filename=a_pepe_by_noizave_dcmga0s\.png}],
          media_files: [{ size: 106_741, width: 750, height: 730 }],
          page_url: "https://sta.sh/0wxs31o7nn2",
          display_name: "noizave",
          username: "noizave",
          profile_url: "https://www.deviantart.com/noizave",
          published_at: Time.parse("2018-09-09T21:04:06.000000Z"),
          updated_at: nil,
          tags: [],
          artist_commentary_title: "A pepe",
          artist_commentary_desc: "This is a test.",
        )
      end

      context "A https://orig00.deviantart.net/* image url with a https://sta.sh/:id referer" do
        strategy_should_work(
          "https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png",
          image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6\.png\?token=.+&filename=a_pepe_by_noizave_dcmga0s\.png}],
          media_files: [{ size: 106_741, width: 750, height: 730 }],
          referer: "https://sta.sh/0wxs31o7nn2",
          page_url: "https://sta.sh/0wxs31o7nn2",
          display_name: "noizave",
          username: "noizave",
          profile_url: "https://www.deviantart.com/noizave",
          published_at: nil,
          updated_at: nil,
          tags: [],
          artist_commentary_title: "A pepe",
          artist_commentary_desc: "This is a test.",
        )
      end

      context "A https://orig00.deviantart.net/* image url without the referer" do
        strategy_should_work(
          "https://orig00.deviantart.net/0fd2/f/2018/252/9/c/a_pepe_by_noizave-dcmga0s.png",
          image_urls: [%r{https://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dcmga0s-a345a815-2436-4ab5-8941-492011e1bff6\.png\?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9\.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTpmaWxlLmRvd25sb2FkIl0sIm9iaiI6W1t7InBhdGgiOiIvZi84M2QzZWI0ZC0xM2U1LTRhZWEtYTA4Zi04ZDQzMzFkMDMzYzQvZGNtZ2Ewcy1hMzQ1YTgxNS0yNDM2LTRhYjUtODk0MS00OTIwMTFlMWJmZjYucG5nIn1dXX0\.b29qVmG1on0SIwS0KhZjYM_LowH0A1NvO9cyvHde-mw}],
          media_files: [{ size: 106_741, width: 750, height: 730 }],
          # if all we have is the image url, then we can't tell that this is really a sta.sh image.
          site_name: "Deviant Art",
          # this is the wrong page, but there's no way to know the correct sta.sh page without the referer.
          page_url: "https://www.deviantart.com/noizave/art/A-Pepe-763305148",
          display_name: nil,
          username: "noizave",
          profile_url: "https://www.deviantart.com/noizave",
          published_at: nil,
          updated_at: nil,
          tags: [],
          artist_commentary_title: nil,
          artist_commentary_desc: nil,
        )
      end
    end
  end
end
