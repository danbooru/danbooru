require 'test_helper'

module Sources
  class PixivTest < ActiveSupport::TestCase
    setup do
      skip "Pixiv credentials not configured" unless Source::Extractor::Pixiv.enabled?
    end

    def assert_illust_id(illust_id, url)
      site = Source::Extractor.find(url)
      assert_equal(illust_id, site.illust_id.to_i)
      assert_nothing_raised { site.to_h }
    end

    def assert_nil_illust_id(url)
      site = Source::Extractor.find(url)
      assert_nil(site.illust_id)
    end

    def get_source(source)
      @site = Source::Extractor.find(source)
      @site
    end

    context "in all cases" do
      context "A gallery page" do
        setup do
          @site = Source::Extractor.find("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=49270482")
          @image_urls = @site.image_urls
        end

        should "get all the image urls" do
          assert_equal(["https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p0.jpg", "https://i.pximg.net/img-original/img/2015/03/14/17/53/32/49270482_p1.jpg"], @image_urls)
        end
      end

      context "An ugoira source site for pixiv" do
        setup do
          @site = Source::Extractor.find("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=62247364")
        end

        should "get the file url" do
          assert_equal(["https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip"], @site.image_urls)
        end

        should "capture the frame data" do
          media_file = @site.download_file!(@site.image_urls.sole)

          assert_equal([125, 125], media_file.frame_delays)
        end
      end

      context "A https://i.pximg.net/img-zip/ugoira/* source" do
        should "get the metadata" do
          @site = Source::Extractor.find("https://i.pximg.net/img-zip-ugoira/img/2017/04/04/08/57/38/62247364_ugoira1920x1080.zip")

          assert_equal("uroobnad2", @site.artist_name)
        end
      end

      context "A https://www.pixiv.net/*/artworks/* source" do
        should "work" do
          @site = Source::Extractor.find("https://www.pixiv.net/en/artworks/64476642")

          assert_equal(["https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg"], @site.image_urls)
          assert_equal("https://www.pixiv.net/artworks/64476642", @site.page_url)

          @site = Source::Extractor.find("https://www.pixiv.net/artworks/64476642")
          assert_equal(["https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg"], @site.image_urls)
          assert_equal("https://www.pixiv.net/artworks/64476642", @site.page_url)
        end
      end

      context "fetching source data for a new manga image" do
        setup do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981735")
        end

        should "get the profile" do
          assert_equal("https://www.pixiv.net/users/696859", @site.profile_url)
        end

        should "get the artist name" do
          assert_equal("uroobnad", @site.artist_name)
        end

        should "get the full size image url" do
          assert_equal(["https://i.pximg.net/img-original/img/2017/11/21/05/12/37/65981735_p0.jpg"], @site.image_urls)
        end

        should "get the page count" do
          assert_equal(1, @site.image_urls.size)
        end

        should "get the tags" do
          pixiv_tags  = @site.tags.map(&:first)
          pixiv_links = @site.tags.map(&:last)

          assert_equal(%w[漫画 test], pixiv_tags)
          assert_contains(pixiv_links, /search\.php/)
        end

        should "get the artist commentary" do
          assert_not_nil(@site.artist_commentary_title)
          assert_not_nil(@site.artist_commentary_desc)
          assert_not_nil(@site.dtext_artist_commentary_title)
          assert_not_nil(@site.dtext_artist_commentary_desc)
        end

        should "convert a page into a json representation" do
          assert_nothing_raised do
            @site.to_json
          end
        end
      end

      context "fetching source data for a new illustration" do
        setup do
          get_source("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46785915")
        end

        should "get the page count" do
          assert_equal(1, @site.image_urls.size)
        end

        should "get the full size image url" do
          assert_equal(["https://i.pximg.net/img-original/img/2014/10/29/09/27/19/46785915_p0.jpg"], @site.image_urls)
        end
      end

      context "fetching source for an illustration with swapped illust_id/mode parameters" do
        setup do
          get_source("https://www.pixiv.net/member_illust.php?illust_id=64476642&mode=medium")
        end

        should "get the page count" do
          assert_equal(1, @site.image_urls.size)
        end

        should "get the full size image url" do
          assert_equal(["https://i.pximg.net/img-original/img/2017/08/18/00/09/21/64476642_p0.jpg"], @site.image_urls)
        end

        should "get the page url" do
          assert_equal("https://www.pixiv.net/artworks/64476642", @site.page_url)
        end
      end

      context "A deleted pixiv post" do
        should "not fail when fetching the source data" do
          @source = "https://i.pximg.net/img-original/img/2018/12/30/01/04/55/72373728_p0.png"
          get_source(@source)

          assert_equal([@source], @site.image_urls)
          assert_nothing_raised { @site.to_h }
        end
      end

      context "A raw image URL that has been revised should get the unrevised image URL" do
        strategy_should_work(
          "https://i.pximg.net/img-original/img/2022/08/14/19/23/06/100474393_p0.png",
          deleted: true,
          image_urls: ["https://i.pximg.net/img-original/img/2022/08/14/19/23/06/100474393_p0.png"],
          artist_commentary_title: "シャイリリー",
          artist_name: "影おじ (隠れエリア)",
          profile_url: "https://www.pixiv.net/users/6570768",
          profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
          tags: %w[r-18 shylily シャイリリー バーチャルyoutuber 両手に茎 乱交],
        )
      end

      context "A post has been revised should get the revised image URLs" do
        strategy_should_work(
          "https://www.pixiv.net/en/artworks/100474393",
          image_urls: %w[
            https://i.pximg.net/img-original/img/2022/08/14/21/21/24/100474393_p0.png
            https://i.pximg.net/img-original/img/2022/08/14/21/21/24/100474393_p1.png
            https://i.pximg.net/img-original/img/2022/08/14/21/21/24/100474393_p2.png
          ],
          artist_commentary_title: "シャイリリー",
          artist_name: "影おじ (隠れエリア)",
          profile_url: "https://www.pixiv.net/users/6570768",
          profile_urls: %w[https://www.pixiv.net/stacc/haku3490 https://www.pixiv.net/users/6570768],
          tags: %w[r-18 shylily シャイリリー バーチャルyoutuber 両手に茎 乱交],
        )
      end

      context "fetching the commentary" do
        should "work when the description is blank" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981746")

          assert_equal("title", @site.dtext_artist_commentary_title)
          assert_equal("desc", @site.dtext_artist_commentary_desc)
        end

        should "convert html to dtext" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65985331")

          dtext_desc = "[b]bold[/b]\n[i]italic[/i]\nred"
          assert_equal(dtext_desc, @site.dtext_artist_commentary_desc)
        end

        should "convert illust links and member links to dtext" do
          get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=63421642")

          dtext_desc = %(foo 【[b]pixiv #46337015 "»":[/posts?tags=pixiv%3A46337015][/b]】bar 【[b]pixiv #14901720 "»":[/posts?tags=pixiv%3A14901720][/b]】\n\nbaz【[b]"user/83739":[https://www.pixiv.net/users/83739] "»":[/artists?search%5Burl_matches%5D=https%3A%2F%2Fwww.pixiv.net%2Fusers%2F83739][/b]】)
          assert_equal(dtext_desc, @site.dtext_artist_commentary_desc)
        end

        should "convert jump.php links" do
          get_source("https://www.pixiv.net/en/artworks/68955584")

          dtext_desc = <<~EOS
            東方や版権中心にまとめました

            ◆例大祭の新刊([b]pixiv #68490887 "»":[/posts?tags=pixiv%3A68490887][/b])を一部加筆して再版しました。通販在庫復活しているのでよろしければ▷<https://www.melonbooks.co.jp/detail/detail.php?product_id=364421>
            今週末京都みやこめっせで開催される「古明地こんぷれっくす　いつつめ」にも持っていきます〜。スペースは【古13】です。他にも色々持って行く予定なので、改めて告知します。

            ◇pixivFANBOX開設してみました。のんびり投稿していく予定です(:˒[￣]メイキングとかやってみたい…▶︎<https://www.pixiv.net/fanbox/creator/143555>
          EOS

          assert_equal(dtext_desc.chomp, @site.dtext_artist_commentary_desc)
        end
      end

      context "translating the tags" do
        setup do
          CurrentUser.user = FactoryBot.create(:user)

          tags = {
            "comic" => "漫画",
            "scenery" => "風景",
            "i-19_(kantai_collection)" => "伊19",
            "mutsu_(kantai_collection)" => "陸奥",
            "fate/grand_order" => "Fate/GrandOrder",
            "fate" => "",
            "foo" => ""
          }

          tags.each do |tag, other_names|
            FactoryBot.create(:tag, name: tag, post_count: 1)
            FactoryBot.create(:wiki_page, title: tag, other_names: other_names)
          end

          @site = get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981746")
          @tags = @site.tags.map(&:first)
          @translated_tags = @site.translated_tags.map(&:name)
        end

        should "get the original tags" do
          assert_equal(["test", "風景", "Fate/GrandOrder", "伊19/陸奥", "鉛筆", "風景10users入り", "foo", "FOO"], @tags)
        end

        should "translate the tag if it matches a wiki other name" do
          assert_includes(@tags, "風景")
          assert_includes(@translated_tags, "scenery")
        end

        should "return the same tag if it doesn't match a wiki other name but it does match a tag" do
          assert_includes(@tags, "foo")
          assert_includes(@translated_tags, "foo")
        end

        should "not translate tags for digital media" do
          assert_equal(false, @tags.include?("Photoshop"))
        end

        should "normalize 10users入り tags" do
          assert_includes(@tags, "風景10users入り")
          assert_includes(@translated_tags, "scenery")
        end

        should "split the base tag if it has no match" do
          assert_includes(@tags, "伊19/陸奥")
          assert_includes(@translated_tags, "i-19_(kantai_collection)")
          assert_includes(@translated_tags, "mutsu_(kantai_collection)")
        end

        should "not split the base tag if it has a match" do
          assert_includes(@tags, "Fate/GrandOrder")
          assert_includes(@translated_tags, "fate/grand_order")
          assert_equal(false, @translated_tags.grep("fate").any?)
        end

        should "apply aliases to translated tags" do
          tohsaka_rin = FactoryBot.create(:tag, name: "tohsaka_rin")
          toosaka_rin = FactoryBot.create(:tag, name: "toosaka_rin")

          FactoryBot.create(:wiki_page, title: "tohsaka_rin", other_names: "遠坂凛")
          FactoryBot.create(:wiki_page, title: "toosaka_rin", other_names: "遠坂凛")
          FactoryBot.create(:tag_alias, antecedent_name: "tohsaka_rin", consequent_name: "toosaka_rin")

          assert_equal([toosaka_rin], @site.translate_tag("遠坂凛"))
        end

        should "not translate '1000users入り' to '1'" do
          FactoryBot.create(:tag, name: "1", post_count: 1)
          source = get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=60665428")
          tags = %w[1000users入り Fate/GrandOrder 「両儀式」 アルジュナ(Fate) アルトリア・ペンドラゴン イシュタル(Fate) グランブルーファンタジー マシュ・キリエライト マーリン(Fate) 手袋]

          assert_equal(tags.sort, source.tags.map(&:first).sort)
          assert_equal(["fate/grand_order"], source.translated_tags.map(&:name))
        end
      end

      context "fetching the artist data" do
        should "get the artist names and profile urls" do
          source = get_source("https://www.pixiv.net/member_illust.php?mode=medium&illust_id=65981746")

          assert_equal("uroobnad", source.tag_name)
          assert_equal(["uroobnad"], source.other_names)
          assert_includes(source.profile_urls, "https://www.pixiv.net/users/696859")
          assert_includes(source.profile_urls, "https://www.pixiv.net/stacc/uroobnad")
        end

        should "not add pixiv-generated 'user_' usernames to the other names field" do
          source = get_source("https://www.pixiv.net/en/artworks/88487025")
          assert_equal(["éé"], source.other_names)
        end
      end

      context "parsing illust ids" do
        should "parse ids from illust urls" do
          assert_illust_id(46785915, "https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg")
          assert_illust_id(79584713, "https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png")

          assert_illust_id(46304396, "http://i1.pixiv.net/img-original/img/2014/10/02/13/51/23/46304396_p0.png")
          assert_illust_id(46304396, "http://i1.pixiv.net/c/600x600/img-master/img/2014/10/02/13/51/23/46304396_p0_master1200.jpg")

          assert_illust_id(14901720, "http://img18.pixiv.net/img/evazion/14901720.png")
          assert_illust_id(14901720, "http://i2.pixiv.net/img18/img/evazion/14901720.png")
          assert_illust_id(14901720, "http://i2.pixiv.net/img18/img/evazion/14901720_m.png")
          assert_illust_id(14901720, "http://i2.pixiv.net/img18/img/evazion/14901720_s.png")

          assert_illust_id(18557054, "http://i1.pixiv.net/img07/img/pasirism/18557054_p1.png")
          assert_illust_id(18557054, "http://i1.pixiv.net/img07/img/pasirism/18557054_big_p1.png")
          assert_illust_id(18557054, "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg")
          assert_illust_id(18557054, "http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_s.png")
          assert_illust_id(18557054, "http://www.pixiv.net/i/18557054")

          assert_illust_id(18557054, "http://www.pixiv.net/en/artworks/18557054")
          assert_illust_id(18557054, "http://www.pixiv.net/artworks/18557054")
        end

        should "parse ids from expicit/guro illust urls" do
          assert_illust_id(46324488, "https://www.pixiv.net/member_illust.php?mode=medium&illust_id=46324488")
          assert_illust_id(46324488, "https://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=46324488&page=0")
          assert_illust_id(46324488, "https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png")
          assert_illust_id(46324488, "https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg")

          assert_illust_id(46323924, "http://i1.pixiv.net/img-zip-ugoira/img/2014/10/03/17/29/16/46323924_ugoira1920x1080.zip")
        end

        should "not misparse ids from novel urls" do
          assert_nil_illust_id("https://i.pximg.net/novel-cover-original/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42.jpg")
          assert_nil_illust_id("https://i.pximg.net/c/600x600/novel-cover-master/img/2019/01/14/01/15/05/10617324_d84daae89092d96bbe66efafec136e42_master1200.jpg")
          assert_nil_illust_id("https://www.pixiv.net/novel/show.php?id=10617324")
        end

        should "not misparse /member_illust.php urls" do
          assert_nil_illust_id("https://www.pixiv.net/member_illust.php")
        end
      end
    end

    should "Parse Pixiv URLs correctly" do
      assert_equal("https://www.pixiv.net/artworks/39749565", Source::URL.page_url("http://i2.pixiv.net/img12/img/zenze/39749565.png"))
      assert_equal("https://www.pixiv.net/artworks/39735353", Source::URL.page_url("http://i1.pixiv.net/img53/img/themare/39735353_big_p1.jpg"))
      assert_equal("https://www.pixiv.net/artworks/14901720", Source::URL.page_url("http://i1.pixiv.net/c/150x150/img-master/img/2010/11/30/08/39/58/14901720_p0_master1200.jpg"))
      assert_equal("https://www.pixiv.net/artworks/14901720", Source::URL.page_url("http://i1.pixiv.net/img-original/img/2010/11/30/08/39/58/14901720_p0.png"))
      assert_equal("https://www.pixiv.net/artworks/44524589", Source::URL.page_url("http://i2.pixiv.net/img-zip-ugoira/img/2014/08/05/06/01/10/44524589_ugoira1920x1080.zip"))

      assert(Source::URL.image_url?("https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png"))
      assert(Source::URL.image_url?("https://i.pximg.net/img-master/img/2014/10/03/18/10/20/46324488_p0_master1200.jpg"))
      assert(Source::URL.image_url?("https://i.pximg.net/img-zip-ugoira/img/2016/04/09/14/25/29/56268141_ugoira1920x1080.zip"))
      assert(Source::URL.image_url?("https://i.pximg.net/c/250x250_80_a2/img-master/img/2014/10/29/09/27/19/46785915_p0_square1200.jpg"))
      assert(Source::URL.image_url?("https://i-f.pximg.net/img-original/img/2020/02/19/00/40/18/79584713_p0.png"))
      assert(Source::URL.image_url?("http://i1.pixiv.net/img-inf/img/2011/05/01/23/28/04/18557054_64x64.jpg"))
      assert(Source::URL.image_url?("http://img18.pixiv.net/img/evazion/14901720.png"))
      assert(Source::URL.image_url?("http://i2.pixiv.net/img18/img/evazion/14901720.png"))

      assert(Source::URL.page_url?("https://www.pixiv.net/en/artworks/46324488"))
      assert(Source::URL.page_url?("https://www.pixiv.net/artworks/46324488"))
      assert(Source::URL.page_url?("http://www.pixiv.net/i/18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=big&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=manga&illust_id=18557054"))
      assert(Source::URL.page_url?("http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=18557054&page=1"))

      assert(Source::URL.profile_url?("https://www.pixiv.net/member.php?id=339253"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/u/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/users/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/en/users/9202877"))
      assert(Source::URL.profile_url?("https://www.pixiv.net/stacc/noizave"))
      assert(Source::URL.profile_url?("http://www.pixiv.me/noizave"))
      assert(Source::URL.profile_url?("https://pixiv.cc/zerousagi/"))
    end
  end
end
