require 'test_helper'

module Sources
  class NewgroundsTest < ActiveSupport::TestCase
    context "A newgrounds post url" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        image_urls: ["https://art.ngfiles.com/images/1539000/1539538_hcnone_sephiroth.png?f1607668234"],
        page_url: "https://www.newgrounds.com/art/view/hcnone/sephiroth",
        download_size: 4_224,
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
        download_size: 4_224,
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
        image_urls: [%r{https://uploads\.ungrounded\.net/alternate/167000/167280_alternate_602\.mp4}],
        profile_url: "https://jenjamik.newgrounds.com",
        artist_name: "jenjamik",
        page_url: "https://www.newgrounds.com/portal/view/536659",
        artist_commentary_title: "Link's Barrel Beat",
        dtext_artist_commentary_desc: /Long time no see!/
      )
    end

    context "A newgrounds direct video url" do
      strategy_should_work(
        "https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.360p.mp4?1639666238",
        image_urls: ["https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4"],
        download_size: 75_605_846
      )
    end

    context "A multi-image post" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/natthelich/weaver",
        image_urls: [
          "https://art.ngfiles.com/images/1520000/1520217_natthelich_weaver.jpg?f1606365031",
          "https://art.ngfiles.com/comments/199000/iu_199826_7115981.jpg",
        ]
      )
    end

    context "A deleted or non-existing post" do
      strategy_should_work(
        "https://www.newgrounds.com/art/view/natthelich/nopicture",
        deleted: true,
        profile_url: "https://natthelich.newgrounds.com",
        artist_name: "natthelich"
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
        dtext_artist_commentary_desc: 'Commission of Annie Hughes, the mom from The Iron Giant, for "@ManStawberry":[https://twitter.com/ManStawberry].'
      )
    end

    should "Parse Newgrounds URLs correctly" do
      assert_equal("https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic", Source::URL.page_url("https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181"))

      assert(Source::URL.image_url?("https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg"))
      assert(Source::URL.image_url?("https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg"))
      assert(Source::URL.image_url?("https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349"))
      assert(Source::URL.image_url?("https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.mp4?1639666238"))

      assert(Source::URL.page_url?("https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat"))
      assert(Source::URL.page_url?("https://www.newgrounds.com/portal/view/830293"))

      assert(Source::URL.profile_url?("https://natthelich.newgrounds.com"))
      assert_not(Source::URL.profile_url?("https://www.newgrounds.com"))
      assert_not(Source::URL.profile_url?("https://newgrounds.com"))
    end
  end
end
