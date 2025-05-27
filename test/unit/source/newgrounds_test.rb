require 'test_helper'

module Sources
  class NewgroundsTest < ActiveSupport::TestCase
    context "A newgrounds post url" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        image_urls: %w[https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234],
        media_files: [{ file_size: 4_224 }],
        page_url: "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        profile_urls: %w[https://hcnone.newgrounds.com],
        display_name: "hcnone",
        username: "hcnone",
        tags: [
          ["sephiroth", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=sephiroth"],
          ["supersmashbros", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=supersmashbros"],
        ],
        dtext_artist_commentary_title: "Sephiroth",
        dtext_artist_commentary_desc: "it's sephiroth, from super smash bros ultimate"
      )
    end

    context "A newgrounds image url" do
      strategy_should_work(
        "https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234",
        image_urls: %w[https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234],
        media_files: [{ file_size: 4_224 }],
        page_url: "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        profile_urls: %w[https://hcnone.newgrounds.com],
        display_name: "hcnone",
        username: "hcnone",
        tags: [
          ["sephiroth", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=sephiroth"],
          ["supersmashbros", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=supersmashbros"],
        ],
        dtext_artist_commentary_title: "Sephiroth",
        dtext_artist_commentary_desc: "it's sephiroth, from super smash bros ultimate"
      )
    end

    context "A newgrounds video post" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/536659",
        image_urls: %w[https://uploads.ungrounded.net/alternate/167000/167280_alternate_602.mp4],
        # media_files: [{ file_size: 137_029_146 }], # XXX filesize too large
        page_url: "https://www.newgrounds.com/portal/view/536659",
        profile_urls: %w[https://jenjamik.newgrounds.com],
        display_name: "Jenjamik",
        username: "jenjamik",
        tags: [
          ["link", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=link"],
          ["loop", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=loop"],
          ["tingle", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=tingle"],
          ["zelda", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=zelda"],
        ],
        dtext_artist_commentary_title: "Link's Barrel Beat",
        dtext_artist_commentary_desc: <<~EOS.chomp
          *This is a LOOP, but things change as you watch for the first few plays*

          Hahahaha, thanks so much everybody for the daily feature and the... SUPER front page :D I'm honored...

          <http://jake-clark.tumblr.com>

          Watch on Youtube: <http://www.youtube.com/watch?v=SsMayq8sL-U>

          Long time no see!

          I don't really know how to explain this, but I hope it keeps you entertained for a good minute or two!
        EOS
      )
    end

    context "A newgrounds video post with no 1080p version" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/758590",
        image_urls: %w[https://uploads.ungrounded.net/alternate/1483000/1483159_alternate_102560.mp4],
        media_files: [{ file_size: 40_583_509 }],
        page_url: "https://www.newgrounds.com/portal/view/758590",
        profile_urls: %w[https://bluethebone.newgrounds.com],
        display_name: "bluethebone",
        username: "bluethebone",
        tags: [
          ["80s-anime", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=80s-anime"],
          ["90s-anime", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=90s-anime"],
          ["anal", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=anal"],
          ["animation", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=animation"],
          ["anime", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=anime"],
          ["fanart", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=fanart"],
          ["guilty-gear", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=guilty-gear"],
          ["hentai", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=hentai"],
          ["jack-o", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=jack-o"],
          ["jack-o-valentine", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=jack-o-valentine"],
          ["retro-anime", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=retro-anime"],
        ],
        dtext_artist_commentary_title: "[ANIMATION W/ SOUND] Jack-O' Valentine [GUILTY GEAR]",
        dtext_artist_commentary_desc: <<~EOS.chomp
          [b]FULL LENGTH VIDEO WITH SOUND HERE[/b]: <https://www.pornhub.com/view_video.php?viewkey=ph5ef177b125770>

          Oh yummy! [b]Jack-O' Valentine[/b] gets a surprise trick-or-treat~

          [b][u]CREDITS[/u][/b]

          Animation by me ([b]BLUETHEBONE[/b])

          Sound Design by [b]ImJustThatKinky [/b]( <https://twitter.com/ImJustThatKinky> )

          Voice by [b]Chloe Angel [/b]( <https://twitter.com/ChloeAngelVA> )

          --

          ♥ Support me on Patreon!: <https://www.patreon.com/bluethebone>

          ♥ Follow me on Twitter!: <https://twitter.com/bluethebone>
        EOS
      )
    end

    context "A newgrounds video post where all images have the resolution in their url" do
      setup do
        skip "Deleted post"
      end

      strategy_should_work(
        "https://www.newgrounds.com/portal/view/734778",
        image_urls: ["https://uploads.ungrounded.net/alternate/1352000/1352451_alternate_80350.1080p.mp4?1563167480"]
      )
    end

    context "A newgrounds direct video url" do
      strategy_should_work(
        "https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.360p.mp4?1639666238",
        image_urls: %w[https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4],
        media_files: [{ file_size: 75_605_846 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A multi-image post" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/natthelich/weaver",
        image_urls: %w[
          https://art.ngfiles.com/images/1520000/1520217_natthelich_weaver.jpg?f1606365031
          https://art.ngfiles.com/comments/199000/iu_199826_7115981.jpg
        ],
        media_files: [
          { file_size: 885_017 },
          { file_size: 91_404 },
        ],
        page_url: "https://www.newgrounds.com/art/view/natthelich/weaver",
        profile_urls: %w[https://natthelich.newgrounds.com],
        display_name: "NatTheLich",
        username: "natthelich",
        tags: [
          ["oc", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=oc"],
          ["spider", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=spider"],
        ],
        dtext_artist_commentary_title: "Weaver",
        dtext_artist_commentary_desc: "\"iu_199826_7115981.jpg\":[https://art.ngfiles.com/comments/199000/iu_199826_7115981.jpg]"
      )
    end

    context "A new image page" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-7-8",
        image_urls: %w[
          https://art.ngfiles.com/images/5235000/5235203_233092_sphenodaile_untitled-5235203.19acabafc67df2351f7125dad47c12cd.jpg?f1700955250
          https://art.ngfiles.com/images/5235000/5235203_233093_sphenodaile_untitled-5235203.19acabafc67df2351f7125dad47c12cd.jpg?f1700955250
        ],
        media_files: [
          { file_size: 3_103_940 },
          { file_size: 3_503_892 },
        ],
        page_url: "https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-7-8",
        profile_urls: %w[https://sphenodaile.newgrounds.com],
        display_name: "Sphenodaile",
        username: "sphenodaile",
        tags: [
          ["bouncy-breasts", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=bouncy-breasts"],
          ["breasts", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=breasts"],
          ["chocker", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=chocker"],
          ["comic", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=comic"],
          ["creampie", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=creampie"],
          ["medieval", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=medieval"],
          ["nsfw", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=nsfw"],
          ["nsfwart", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=nsfwart"],
          ["oc", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=oc"],
          ["princess-of-the-thorns", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=princess-of-the-thorns"],
          ["unusual-pupils", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=unusual-pupils"],
          ["x-ray", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=x-ray"],
        ],
        dtext_artist_commentary_title: "\"Princess of the Thorns\" pages 7-8!❤️‍🔥",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "Princess of the Thorns" pages 7-8, halfway there!

          And, of course, pages 9-10 are also available for my "Patreon":[https://www.patreon.com/sphenodaile] supporters as early access.
        EOS
      )
    end

    context "A new multi-image gallery" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-11-12-afterwords",
        image_urls: %w[
          https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.webp?f1702161429
          https://art.ngfiles.com/images/5267000/5267492_276883_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.81ca470f3d2830104e142d2e2b610e4c.jpg?f1702161410
          https://art.ngfiles.com/images/5267000/5267492_276881_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.9ece029ebd69b6e55dbaf777a30b0e79.webp?f1702161437
          https://art.ngfiles.com/images/5267000/5267492_276882_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.462b90641c2487627650683f5002c0be.webp?f1702161443
        ],
        media_files: [
          { file_size: 2_076_674 },
          { file_size: 4_608_194 },
          { file_size: 3_165_472 },
          { file_size: 1_047_638 },
        ],
        page_url: "https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-11-12-afterwords",
        profile_urls: %w[https://sphenodaile.newgrounds.com],
        display_name: "Sphenodaile",
        username: "sphenodaile",
        tags: [
          ["comic", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=comic"],
          ["medieval", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=medieval"],
          ["oc", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=oc"],
          ["princess-of-the-thorns", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=princess-of-the-thorns"],
        ],
        dtext_artist_commentary_title: "\"Princess of the Thorns\" pages 11-12 + afterwords🌹",
        dtext_artist_commentary_desc: <<~EOS.chomp
          I DID IT! 🎉

          Still can't believe I actually finished it😁

          Thank you all for supporting me and following this comic!☺️❤️
        EOS
      )
    end

    context "A new sample image" do
      strategy_should_work(
        "https://art.ngfiles.com/medium_views/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.webp?f1702161430",
        image_urls: %w[https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161430],
        media_files: [{ file_size: 2_107_866 }],
        page_url: nil,
        profile_urls: %w[https://sphenodaile.newgrounds.com],
        display_name: nil,
        username: "sphenodaile",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A new full size image" do
      strategy_should_work(
        "https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161430",
        image_urls: %w[https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161430],
        media_files: [{ file_size: 2_107_866 }],
        page_url: nil,
        profile_urls: %w[https://sphenodaile.newgrounds.com],
        display_name: nil,
        username: "sphenodaile",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A deleted or non-existing post" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/natthelich/nopicture",
        image_urls: [],
        page_url: "https://www.newgrounds.com/art/view/natthelich/nopicture",
        profile_urls: %w[https://natthelich.newgrounds.com],
        display_name: nil,
        username: "natthelich",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A deleted or non-existing video" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/802594",
        deleted: true,
        image_urls: [],
        profile_url: nil
      )
    end

    context "A www.newgrounds.com/dump/item URL" do
      strategy_should_work(
        "https://www.newgrounds.com/dump/item/a1f417d20f5eaef31e26ac3c4956b3d4",
        image_urls: [],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A post with links to other illustrations not belonging to the commentary" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/boxofwant/annie-hughes-1",
        image_urls: %w[https://art.ngfiles.com/images/1574000/1574394_boxofwant_annie-hughes-1.jpg?f1609746123],
        media_files: [{ file_size: 44_930_583 }],
        page_url: "https://www.newgrounds.com/art/view/boxofwant/annie-hughes-1",
        profile_urls: %w[https://boxofwant.newgrounds.com],
        display_name: "BoxOfWant",
        username: "boxofwant",
        tags: [
          ["annie-hughes", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=annie-hughes"],
          ["iron-giant", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=iron-giant"],
        ],
        dtext_artist_commentary_title: "Annie Hughes 1",
        dtext_artist_commentary_desc: "Commission of Annie Hughes, the mom from The Iron Giant, for \"@ManStawberry\":[https://twitter.com/ManStawberry]."
      )
    end

    context "A video credited to multiple users" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/874316",
        image_urls: %w[https://uploads.ungrounded.net/alternate/4520000/4520879_alternate_210456.mp4],
        media_files: [{ file_size: 13_975_241 }],
        page_url: "https://www.newgrounds.com/portal/view/874316",
        profile_urls: %w[https://jakada.newgrounds.com],
        display_name: "Jakada",
        username: "jakada",
        tags: [
          ["doggystyle", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=doggystyle"],
          ["monster-girl", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=monster-girl"],
          ["nijisanji", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=nijisanji"],
          ["selen", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=selen"],
          ["selen-tatsuki", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=selen-tatsuki"],
          ["vtuber", "https://www.newgrounds.com/search/conduct/art?match=tags&tags=vtuber"],
        ],
        dtext_artist_commentary_title: "Selen Tatsuki",
        dtext_artist_commentary_desc: <<~EOS.chomp
          VA&SFX courtesy of BrittanyBabbles

          --------------------------------------------------------------

          Follow me on twitter if you liked! Im posting a lot of wips for my upcoming nsfw animation project there <https://twitter.com/jakada_ani>
        EOS
      )
    end

    should "Parse Newgrounds URLs correctly" do
      assert_equal("https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic", Source::URL.page_url("https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181"))

      assert(Source::URL.image_url?("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg"))
      assert(Source::URL.image_url?("https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg"))
      assert(Source::URL.image_url?("https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349"))
      assert(Source::URL.image_url?("https://art.ngfiles.com/medium_views/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860"))
      assert(Source::URL.image_url?("https://art.ngfiles.com/images/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860"))
      assert(Source::URL.image_url?("https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4?1639666238"))

      assert(Source::URL.page_url?("https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat"))
      assert(Source::URL.page_url?("https://www.newgrounds.com/portal/view/830293"))

      assert(Source::URL.profile_url?("https://natthelich.newgrounds.com"))
      assert_not(Source::URL.profile_url?("https://www.newgrounds.com"))
      assert_not(Source::URL.profile_url?("https://newgrounds.com"))

      assert_nil(Source::URL.page_url("https://art.ngfiles.com/medium_views/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595860"))
      assert_equal("https://www.newgrounds.com/art/view/natthelich/pandora", Source::URL.page_url("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg")) # XXX dead page
      assert_equal("https://www.newgrounds.com/art/view/natthelich/pandora-2", Source::URL.page_url("https://art.ngfiles.com/images/1543000/1543982_natthelich_pandora-2.jpg?f1607971817"))
    end
  end
end
