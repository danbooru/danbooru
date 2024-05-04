require 'test_helper'

module Sources
  class NewgroundsTest < ActiveSupport::TestCase
    context "A newgrounds post url" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        image_urls: ["https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234"],
        page_url: "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        media_files: [{ file_size: 4_224 }],
        artist_name: "hcnone",
        profile_url: "https://hcnone.newgrounds.com",
        artist_commentary_title: "Sephiroth",
        tags: [
          %w[sephiroth https://www.newgrounds.com/search/conduct/art?match=tags&tags=sephiroth],
          %w[supersmashbros https://www.newgrounds.com/search/conduct/art?match=tags&tags=supersmashbros],
        ]
      )
    end

    context "A newgrounds image url" do
      strategy_should_work(
        "https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234",
        image_urls: ["https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234"],
        page_url: "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        media_files: [{ file_size: 4_224 }],
        artist_name: "hcnone",
        profile_url: "https://hcnone.newgrounds.com",
        artist_commentary_title: "Sephiroth",
        tags: [
          %w[sephiroth https://www.newgrounds.com/search/conduct/art?match=tags&tags=sephiroth],
          %w[supersmashbros https://www.newgrounds.com/search/conduct/art?match=tags&tags=supersmashbros],
        ]
      )
    end

    context "A newgrounds video post" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/536659",
        image_urls: ["https://uploads.ungrounded.net/alternate/167000/167280_alternate_602.mp4"],
        profile_url: "https://jenjamik.newgrounds.com",
        artist_name: "Jenjamik",
        other_names: ["Jenjamik"],
        tag_name: "jenjamik",
        page_url: "https://www.newgrounds.com/portal/view/536659",
        artist_commentary_title: "Link's Barrel Beat",
        dtext_artist_commentary_desc: /Long time no see!/
      )
    end

    context "A newgrounds video post with no 1080p version" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/758590",
        image_urls: ["https://uploads.ungrounded.net/alternate/1483000/1483159_alternate_102560.mp4"]
      )
    end

    context "A newgrounds video post where all images have the resolution in their url" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/734778",
        image_urls: ["https://uploads.ungrounded.net/alternate/1352000/1352451_alternate_80350.1080p.mp4?1563167480"]
      )
    end

    context "A newgrounds direct video url" do
      strategy_should_work(
        "https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.360p.mp4?1639666238",
        image_urls: ["https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4"],
        media_files: [{ file_size: 75_605_846 }]
      )
    end

    context "A multi-image post" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/natthelich/weaver",
        image_urls: %w[
          https://art.ngfiles.com/images/1520000/1520217_natthelich_weaver.jpg?f1606365031
          https://art.ngfiles.com/comments/199000/iu_199826_7115981.jpg
        ],
        profile_url: "https://natthelich.newgrounds.com",
        artist_name: "NatTheLich",
        other_names: ["NatTheLich"],
        tag_name: "natthelich",
      )
    end

    context "A new image page" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-7-8",
        image_urls: %w[
          https://art.ngfiles.com/images/5235000/5235203_233092_sphenodaile_untitled-5235203.19acabafc67df2351f7125dad47c12cd.jpg?f1700955250
          https://art.ngfiles.com/images/5235000/5235203_233093_sphenodaile_untitled-5235203.19acabafc67df2351f7125dad47c12cd.jpg?f1700955250
        ],
      )
    end

    context "A new multi-image gallery" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-11-12-afterwords",
        image_urls: %w[
          https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161372
          https://art.ngfiles.com/images/5267000/5267492_276883_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.81ca470f3d2830104e142d2e2b610e4c.jpg?f1702161410
          https://art.ngfiles.com/images/5267000/5267492_276881_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.9ece029ebd69b6e55dbaf777a30b0e79.jpg?f1702161407
          https://art.ngfiles.com/images/5267000/5267492_276882_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.462b90641c2487627650683f5002c0be.jpg?f1702161408
        ],
      )
    end

    context "A new sample image" do
      strategy_should_work(
        "https://art.ngfiles.com/medium_views/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.webp?f1702161430",
        image_urls: [
          %r!https://art\.ngfiles\.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords\.1403130356bd217fb99f7ae3f9ce6029\.jpg!
        ],
        media_files: [
          { file_size: 2_107_866 },
        ],
        page_url: nil,
        profile_url: "https://sphenodaile.newgrounds.com",
        artist_name: "sphenodaile",
        other_names: ["sphenodaile"],
        tag_name: "sphenodaile",
      )
    end

    context "A new full size image" do
      strategy_should_work(
        "https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161430",
        image_urls: [
          %r!https://art\.ngfiles\.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords\.1403130356bd217fb99f7ae3f9ce6029\.jpg!
        ],
        media_files: [
          { file_size: 2_107_866 },
        ],
        page_url: nil,
        profile_url: "https://sphenodaile.newgrounds.com",
        artist_name: "sphenodaile",
        other_names: ["sphenodaile"],
        tag_name: "sphenodaile",
      )
    end

    context "A deleted or non-existing post" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/natthelich/nopicture",
        deleted: true,
        image_urls: [],
        profile_url: "https://natthelich.newgrounds.com",
        artist_name: "natthelich",
        other_names: ["natthelich"],
        tag_name: "natthelich",
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
        artist_name: nil,
        profile_url: nil
      )
    end

    context "A post with links to other illustrations not belonging to the commentary" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/boxofwant/annie-hughes-1",
        profile_url: "https://boxofwant.newgrounds.com",
        artist_name: "BoxOfWant",
        other_names: ["BoxOfWant"],
        tag_name: "boxofwant",
        dtext_artist_commentary_desc: 'Commission of Annie Hughes, the mom from The Iron Giant, for "@ManStawberry":[https://twitter.com/ManStawberry].'
      )
    end

    context "A video credited to multiple users" do
      strategy_should_work(
        "https://www.newgrounds.com/portal/view/874316",
        image_urls: ["https://uploads.ungrounded.net/alternate/4520000/4520879_alternate_210456.mp4"],
        profile_url: "https://jakada.newgrounds.com",
        artist_name: "Jakada",
        other_names: ["Jakada"],
        tag_name: "jakada",
        artist_commentary_title: "Selen Tatsuki",
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
