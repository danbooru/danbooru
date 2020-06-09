require 'test_helper'

module Sources
  class DeviantArtTest < ActiveSupport::TestCase
    def setup
      super
      skip "DeviantArt API keys not set" unless Danbooru.config.deviantart_client_id.present?
    end

    context "A page url" do
      setup do
        @site = Sources::Strategies.find("https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484")
      end

      should "work" do
        # http://origin-orig.deviantart.net/d533/f/2014/004/8/d/holiday_elincia_by_aeror404-d70rm0s.jpg (md5: a7651a6586b95c62fd593dd34bb13618, size: 877987)
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(877_987, @site.image_url)

        assert_equal("aeror404", @site.artist_name)
        assert_equal("https://www.deviantart.com/aeror404", @site.profile_url)
        assert_equal("https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484", @site.page_url)
        assert_equal("https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484", @site.page_url_from_image_url)
        assert_equal("https://www.deviantart.com/aeror404/art/Holiday-Elincia-424551484", @site.canonical_url)
        assert_equal("Holiday Elincia", @site.artist_commentary_title)
      end
    end

    context "The source for a deleted DeviantArt image URL" do
      should "work" do
        @site = Sources::Strategies.find("https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png")
        @artist = create(:artist, name: "nickbeja", url_string: "https://nickbeja.deviantart.com")

        assert_equal("https://pre00.deviantart.net/423b/th/pre/i/2017/281/e/0/mindflayer_girl01_by_nickbeja-dbpxdt8.png", @site.image_url)
        assert_equal(@site.page_url, @site.canonical_url)
        assert_equal("nickbeja", @site.artist_name)
        assert_equal("https://www.deviantart.com/nickbeja", @site.profile_url)
        assert_equal("https://www.deviantart.com/nickbeja/art/Mindflayer-Girl01-708675884", @site.page_url_from_image_url)
        assert_equal([@artist], @site.artists)
        assert_nothing_raised { @site.to_h }
      end
    end

    context "The source for a download-disabled DeviantArt artwork page" do
      should "get the image url" do
        @site = Sources::Strategies.find("https://noizave.deviantart.com/art/test-no-download-697415967")

        # https://img00.deviantart.net/56ee/i/2017/219/2/3/test__no_download_by_noizave-dbj81lr.jpg (md5: 25a03b5a6744b6b914a13b3cd50e3c2c, size: 37638)
        # orig file: https://danbooru.donmai.us/posts/463438 (md5: eb97244675e47dbd77ffcd2d7e15aeab, size: 59401)
        assert_match("https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/83d3eb4d-13e5-4aea-a08f-8d4331d033c4/dbj81lr-3306feb1-87dc-4d25-9a4c-da8d2973a8b7.jpg", @site.image_url)
        assert_downloaded(40_036, @site.image_url)

        assert_equal("noizave", @site.artist_name)
        assert_equal("https://www.deviantart.com/noizave", @site.profile_url)
        assert_equal("test, no download", @site.artist_commentary_title)
        assert_equal("https://www.deviantart.com/noizave/art/test-no-download-697415967", @site.page_url)
        assert_equal("https://www.deviantart.com/noizave/art/Test-No-Download-697415967", @site.page_url_from_image_url)
        assert_equal("https://www.deviantart.com/noizave/art/test-no-download-697415967", @site.canonical_url)
      end
    end

    context "The source for a download-enabled DeviantArt artwork page" do
      should "get the download image url" do
        @site = Sources::Strategies.find("https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781")

        # http://origin-orig.deviantart.net/a713/f/2018/333/3/6/all_that_glitters_ii_by_len1-dct67m5.jpg (md5: d16bb8620600334caa029ebb9bc426a6, size: 1402017)
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(1402017, @site.image_url)

        assert_equal("len1", @site.artist_name)
        assert_equal("https://www.deviantart.com/len1", @site.profile_url)
        assert_equal("All that Glitters II", @site.artist_commentary_title)
        assert_equal("https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781", @site.page_url)
        assert_equal("https://www.deviantart.com/len1/art/All-that-Glitters-II-774592781", @site.canonical_url)
      end
    end

    context "The source for a DeviantArt image url" do
      should "fetch the source data" do
        @site = Sources::Strategies.find("https://pre00.deviantart.net/b5e6/th/pre/f/2016/265/3/5/legend_of_galactic_heroes_by_hideyoshi-daihpha.jpg")

        # http://origin-orig.deviantart.net/9e1f/f/2016/265/3/5/legend_of_galactic_heroes_by_hideyoshi-daihpha.jpg (md5: 4cfec3d50ebbb924077cc5c90e705d4e, size: 906621)
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(906_621, @site.image_url)

        assert_equal("hideyoshi", @site.artist_name)
        assert_equal("https://www.deviantart.com/hideyoshi", @site.profile_url)
        assert_equal("https://www.deviantart.com/hideyoshi/art/Legend-of-Galactic-Heroes-635721022", @site.page_url)
        assert_equal("https://www.deviantart.com/hideyoshi/art/Legend-Of-Galactic-Heroes-635721022", @site.page_url_from_image_url)
        assert_equal("https://www.deviantart.com/hideyoshi/art/Legend-of-Galactic-Heroes-635721022", @site.canonical_url)
        assert_equal(%w[barbarossa bay brunhild flare hangar odin planet ship spaceship sun sunset brünhild legendsofgalacticheroes].sort, @site.tags.map(&:first).sort)
      end
    end

    context "The source for a origin-orig.deviantart.net image url without a referer" do
      should "work" do
        @site = Sources::Strategies.find("http://origin-orig.deviantart.net/7b5b/f/2017/160/c/5/test_post_please_ignore_by_noizave-dbc3a48.png")

        # md5: 9dec050536dbdb09ab63cb9c5a48f8b7
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(3619, @site.image_url)

        assert_equal("https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408", @site.page_url)
        assert_equal("https://www.deviantart.com/noizave/art/Test-Post-Please-Ignore-685436408", @site.page_url_from_image_url)
        assert_equal("https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408", @site.canonical_url)

        assert_equal("noizave", @site.artist_name)
        assert_equal("https://www.deviantart.com/noizave", @site.profile_url)
        assert_equal(%w[bar baz foo], @site.tags.map(&:first))
        assert_nothing_raised { @site.to_h }
      end
    end

    context "The source for a img00.deviantart.net sample image url" do
      should "return the full size image url" do
        @site = Sources::Strategies.find("https://img00.deviantart.net/a233/i/2017/160/5/1/test_post_please_ignore_by_noizave-dbc3a48.png")

        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(3619, @site.image_url)

        assert_equal("https://www.deviantart.com/noizave/art/Test-Post-Please-Ignore-685436408", @site.page_url_from_image_url)
      end
    end

    context "The source for a th00.deviantart.net/*/PRE/* thumbnail url" do
      should "return the full size image url" do
        @site = Sources::Strategies.find("http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png")

        # http://origin-orig.deviantart.net/0f1e/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png (md5: d779f5a7da29ec90d777a8db38d07994, size: 3391584)
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(3_391_584, @site.image_url)

        assert_equal("https://www.deviantart.com/xyelkiltrox/art/Goruto-438744629", @site.page_url_from_image_url)
      end
    end

    context "A source for a *.deviantart.net/*/:title_by_:artist.jpg url artist name containing underscores" do
      should "find the correct artist" do
        @site = Sources::Strategies.find("https://orig00.deviantart.net/4274/f/2010/230/8/a/pkmn_king_and_queen_by_mikoto_chan.jpg")
        @artist = create(:artist, name: "mikoto-chan", url_string: "https://www.deviantart.com/mikoto-chan")

        assert_equal("mikoto-chan", @site.artist_name)
        assert_equal([@artist], @site.artists)
        assert_nil(@site.page_url_from_image_url)
      end
    end

    context "The source for a *.deviantart.net/*/:title_by_:artist.jpg url" do
      setup do
        @url = "http://fc08.deviantart.net/files/f/2007/120/c/9/cool_like_me_by_47ness.jpg"
        @ref = "https://47ness.deviantart.com/art/Cool-Like-Me-54339311"
        @artist = create(:artist, name: "47ness", url_string: "https://www.deviantart.com/47ness")
      end

      context "without a referer" do
        should "work" do
          @site = Sources::Strategies.find(@url)

          assert_equal(@site.url, @site.image_url)
          assert_equal("47ness", @site.artist_name)
          assert_equal("https://www.deviantart.com/47ness", @site.profile_url)
          assert_nil(@site.page_url)
          assert_nil(@site.page_url_from_image_url)
          assert_equal(@site.image_url, @site.canonical_url)
          assert_equal([@artist], @site.artists)
          assert_nothing_raised { @site.to_h }
        end
      end

      context "with a referer" do
        should "work" do
          @site = Sources::Strategies.find(@url, @ref)

          # http://origin-orig.deviantart.net/a418/f/2007/120/c/9/cool_like_me_by_47ness.jpg (md5: da78e7c192d42470acda7d87ade64849, size: 265496)
          assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
          assert_downloaded(265_496, @site.image_url)

          assert_equal("47ness", @site.artist_name)
          assert_equal("https://www.deviantart.com/47ness", @site.profile_url)
          assert_equal("https://www.deviantart.com/47ness/art/Cool-Like-Me-54339311", @site.page_url)
          assert_equal(@site.page_url, @site.canonical_url)
          assert_equal([@artist], @site.artists)
          assert_nothing_raised { @site.to_h }
        end
      end
    end

    context "The source for a *.deviantart.net/*/:hash.jpg url" do
      setup do
        @url = "http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg"
        @ref = "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896"
        @artist = create(:artist, name: "edsfox", url_string: "https://edsfox.deviantart.com")
      end

      context "without a referer" do
        should "work" do
          @site = Sources::Strategies.find(@url)

          assert_equal(@url, @site.image_url)
          assert_nil(@site.artist_name)
          assert_nil(@site.profile_url)
          assert_nil(@site.page_url)
          assert_nil(@site.page_url_from_image_url)
          assert_equal(@site.image_url, @site.canonical_url)
          assert_equal([], @site.artists)
          assert_nothing_raised { @site.to_h }
        end
      end

      context "with a referer" do
        should "work" do
          @site = Sources::Strategies.find(@url, @ref)

          assert_match(%r!\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg!, @site.image_url)
          assert_equal("edsfox", @site.artist_name)
          assert_equal("https://www.deviantart.com/edsfox", @site.profile_url)
          assert_equal("https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896", @site.page_url)
          assert_equal(@site.page_url, @site.canonical_url)
          assert_equal([@artist], @site.artists)
          assert_nothing_raised { @site.to_h }
        end
      end
    end

    context "The source for a images-wixmp-.* sample image" do
      setup do
        @url = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg"
        @ref = "https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896"
        @artist = create(:artist, name: "edsfox", url_string: "https://edsfox.deviantart.com")
      end

      context "with a referer" do
        should "work" do
          @site = Sources::Strategies.find(@url, @ref)

          assert_match(%r!\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg!, @site.image_url)
          assert_equal("edsfox", @site.artist_name)
          assert_equal("https://www.deviantart.com/edsfox", @site.profile_url)
          assert_equal("https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896", @site.page_url)
          assert_equal(@site.page_url, @site.canonical_url)
          assert_equal([@artist], @site.artists)
          assert_nothing_raised { @site.to_h }
        end
      end
    end

    context "The source for a api-da.wixmp.com image" do
      setup do
        @url = "https://api-da.wixmp.com/_api/download/file?downloadToken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwiaXNzIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImV4cCI6MTU5MDkwMTUzMywiaWF0IjoxNTkwOTAwOTIzLCJqdGkiOiI1ZWQzMzhjNWQ5YjI0Iiwib2JqIjpudWxsLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdLCJwYXlsb2FkIjp7InBhdGgiOiJcL2ZcL2U0NmE0OGViLTNkMGItNDQ5ZS05MGRjLTBhMWIzMWNiMTM2MVwvZGQzcDF4OS1mYjQ3YmM4Zi02NTNlLTQyYTItYmI0ZC1hZmFmOWZjMmI3ODEuanBnIn19.-zo8E2eDmkmDNCK-sMabBajkaGtVYJ2Q20iVrUtt05Q"
        @ref = "https://www.deviantart.com/akizero1510/art/Ten-miles-of-cherry-blossoms-792268029"
        @artist = create(:artist, name: "akizero", url_string: "https://akizero1510.deviantart.com")
      end

      context "with a referer" do
        should "work" do
          @site = Sources::Strategies.find(@url, @ref)

          assert_equal(@ref, @site.page_url)
          assert_equal(@ref, @site.canonical_url)
          assert_equal([@artist], @site.artists)
          assert_nothing_raised { @site.to_h }
        end
      end
    end

    context "The source for a non-downloadable animated gif with id<=790677560" do
      should "return working image url" do
        @site = Sources::Strategies.find("https://www.deviantart.com/heartgear/art/Silent-Night-579982816")

        # md5: 62caac1863aa264a56d548b4b7607097
        assert_match(%r!\Ahttps://images-wixmp-ed30a86b8c4ca887773594c2\.wixmp\.com/f/ea95be00-c5aa-4063-bd55-f5a9183912f7/d9lb1ls-7d625444-0003-4123-bf00-274737ca7fdd.gif\?token=!, @site.image_url)
        assert_downloaded(350_156, @site.image_url)
      end
    end

    context "The source for a non-downloadable flash file" do
      should "return working image url" do
        @site = Sources::Strategies.find("https://www.deviantart.com/heartgear/art/SL-40v3-522007633")

        # md5: 6adf1a3d532f898f44cf9948cbc7db7d
        assert_match(%r!\Ahttps://api-da\.wixmp\.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(3_496_110, @site.image_url)
      end
    end

    context "The source for a non-downloadable video file" do
      should "return working image url" do
        @site = Sources::Strategies.find("https://www.deviantart.com/gs-mantis/art/Chen-Goes-Fishing-505847233")

        # md5: 344ac2b9fd5a87982af4b648aa2b2b0d
        assert_equal("https://wixmp-ed30a86b8c4ca887773594c2.wixmp.com/v/mp4/fe046bc7-4d68-4699-96c1-19aa464edff6/d8d6281-91959e92-214f-4b2d-a138-ace09f4b6d09.1080p.8e57939eba634743a9fa41185e398d00.mp4", @site.image_url)
        assert_downloaded(9_739_947, @site.image_url)
      end
    end

    context "The source for an DeviantArt artwork page" do
      setup do
        @site = Sources::Strategies.find("http://noizave.deviantart.com/art/test-post-please-ignore-685436408")
      end

      should "get the image url" do
        # https://origin-orig.deviantart.net/7b5b/f/2017/160/c/5/test_post_please_ignore_by_noizave-dbc3a48.png
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(3619, @site.image_url)
      end

      should "get the profile" do
        assert_equal("https://www.deviantart.com/noizave", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("noizave", @site.artist_name)
      end

      should "get the tags" do
        assert_equal(%w[bar baz foo], @site.tags.map(&:first))
      end

      should "get the artist commentary" do
        title = "test post please ignore"
        desc = "<div align=\"center\"><span>blah blah<br /><div align=\"left\"><a class=\"external\" href=\"https://www.deviantart.com/users/outgoing?http://www.google.com\">test link</a><br /></div></span></div><br /><h1>lol</h1><br /><br /><b>blah</b>&nbsp;<i>blah</i>&nbsp;<u>blah</u>&nbsp;<strike>blah</strike><br />herp derp<br /><br /><blockquote>this is a quote</blockquote><ol><li>one</li><li>two</li><li>three</li></ol><ul><li>one</li><li>two</li><li>three</li></ul><img src=\"https://e.deviantart.net/emoticons/h/heart.gif\" alt=\"Heart\" style=\"width: 15px; height: 13px;\" data-embed-type=\"emoticon\" data-embed-id=\"357\">&nbsp;&nbsp;"

        assert_equal(title, @site.artist_commentary_title)
        assert_equal(desc, @site.artist_commentary_desc)
      end

      should "get the dtext-ified commentary" do
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

        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end

    context "The source for a login-only DeviantArt artwork page" do
      setup do
        @site = Sources::Strategies.find("http://noizave.deviantart.com/art/hidden-work-685458369")
      end

      should "get the image url" do
        # https://origin-orig.deviantart.net/cb25/f/2017/160/1/9/hidden_work_by_noizave-dbc3r29.png
        assert_match(%r!\Ahttps://api-da.wixmp.com/_api/download/file\?downloadToken=!, @site.image_url)
        assert_downloaded(3619, @site.image_url)
      end
    end

    context "A source with malformed links in the artist commentary" do
      should "fix the links" do
        @site = Sources::Strategies.find("https://teemutaiga.deviantart.com/art/Kisu-620666655")

        assert_match(%r!"Print available at Inprnt":\[http://www.inprnt.com/gallery/teemutaiga/kisu\]!, @site.dtext_artist_commentary_desc)
      end
    end

    context "An artist entry with a profile url that is missing the 'www'" do
      should "still find the artist" do
        @site = Sources::Strategies.find("http://noizave.deviantart.com/art/test-post-please-ignore-685436408")
        @artist = create(:artist, name: "noizave", url_string: "https://deviantart.com/noizave")

        assert_equal([@artist], @site.artists)
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "http://fc06.deviantart.net/fs71/f/2013/295/d/7/you_are_already_dead__by_mar11co-d6rgm0e.jpg"
        source2 = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg"
        source3 = "http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png"
        source4 = "http://fc00.deviantart.net/fs71/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg"
        source5 = "https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/76098ac8-04ab-4784-b382-88ca082ba9b1/d9x7lmk-595099de-fe8f-48e5-9841-7254f9b2ab8d.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1cm46YXBwOiIsImlzcyI6InVybjphcHA6Iiwib2JqIjpbW3sicGF0aCI6IlwvZlwvNzYwOThhYzgtMDRhYi00Nzg0LWIzODItODhjYTA4MmJhOWIxXC9kOXg3bG1rLTU5NTA5OWRlLWZlOGYtNDhlNS05ODQxLTcyNTRmOWIyYWI4ZC5wbmcifV1dLCJhdWQiOlsidXJuOnNlcnZpY2U6ZmlsZS5kb3dubG9hZCJdfQ.KFOVXAiF8MTlLb3oM-FlD0nnDvODmjqEhFYN5I2X5Bc"
        source6 = "https://fav.me/dbc3a48"

        assert_equal("https://www.deviantart.com/mar11co/art/You-Are-Already-Dead-408921710", Sources::Strategies.normalize_source(source1))
        assert_equal("https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896", Sources::Strategies.normalize_source(source2))
        assert_equal("https://www.deviantart.com/melisaongmiqin/art/Illustration-Tokyo-Encount-Oei-659256076", Sources::Strategies.normalize_source(source3))
        assert_equal("https://www.deviantart.com/deviation/417560500", Sources::Strategies.normalize_source(source4))
        assert_equal("https://www.deviantart.com/deviation/599977532", Sources::Strategies.normalize_source(source5))
        assert_equal("https://www.deviantart.com/deviation/685436408", Sources::Strategies.normalize_source(source6))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source1 = "http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg"
        bad_source2 = "http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg"
        bad_source3 = "https://deviantart.net"
        assert_equal(bad_source1, Sources::Strategies.normalize_source(bad_source1))
        assert_equal(bad_source2, Sources::Strategies.normalize_source(bad_source2))
        assert_equal(bad_source3, Sources::Strategies.normalize_source(bad_source3))
      end
    end
  end
end
