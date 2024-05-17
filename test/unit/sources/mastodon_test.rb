require 'test_helper'

module Sources
  class MastodonTest < ActiveSupport::TestCase
    context "For Pawoo," do
      setup do
        skip "Pawoo keys not set" unless Danbooru.config.pawoo_access_token
      end

      context "a https://pawoo.net/web/status/$id url" do
        strategy_should_work(
          "https://pawoo.net/web/statuses/1202176",
          image_urls: ["https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png"],
          profile_url: "https://pawoo.net/@9ed00e924818",
          username: "9ed00e924818",
          display_name: nil,
          dtext_artist_commentary_desc: "a mind forever voyaging through strange seas of thought alone",
          media_files: [{ file_size: 7_680 }],
        )
      end

      context "a https://pawoo.net/$user/$id url" do
        desc = <<~DESC.chomp
          test post please ignore

          blah blah blah

          this is a test 🍕

          "#foo":[https://pawoo.net/tags/foo] "#bar":[https://pawoo.net/tags/bar] "#baz":[https://pawoo.net/tags/baz]
        DESC

        strategy_should_work(
          "https://pawoo.net/@evazion/19451018",
          image_urls: %w[
            https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png
            https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4
            https://img.pawoo.net/media_attachments/files/001/298/081/original/2588ee9ba808f38f.webm
            https://img.pawoo.net/media_attachments/files/001/298/084/original/media.mp4
          ],
          profile_urls: %w[https://pawoo.net/@evazion https://pawoo.net/web/accounts/47806],
          username: "evazion",
          display_name: nil,
          tags: %w[foo bar baz],
          dtext_artist_commentary_desc: desc
        )
      end

      context "a https://img.pawoo.net/ url" do
        strategy_should_work(
          "https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4",
          image_urls: ["https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4"],
          media_files: [{ file_size: 59_950 }],
          referer: "https://pawoo.net/@evazion/19451018",
          page_url: "https://pawoo.net/@evazion/19451018"
        )
      end

      context "a deleted or invalid source" do
        strategy_should_work(
          "https://pawoo.net/@nonamethankswashere/12345678901234567890",
          profile_url: "https://pawoo.net/@nonamethankswashere",
          username: "nonamethankswashere",
          deleted: true
        )
      end
    end

    context "For Baraag," do
      setup do
        skip "Baraag keys not set" unless Danbooru.config.baraag_access_token
      end

      context "a baraag.net/$user/$id url" do
        strategy_should_work(
          "https://baraag.net/@bardbot/105732813175612920",
          image_urls: ["https://media.baraag.net/media_attachments/files/105/732/803/241/495/700/original/556e1eb7f5ca610f.png"],
          media_files: [{ file_size: 573_353 }],
          profile_url: "https://baraag.net/@bardbot",
          username: "bardbot",
          display_name: "SpicyBardo🔞",
          dtext_artist_commentary_desc: "🍌"
        )
      end

      context "an old baraag image url" do
        strategy_should_work(
          "https://baraag.net/system/media_attachments/files/105/803/948/862/719/091/original/54e1cb7ca33ec449.png",
          image_urls: ["https://media.baraag.net/media_attachments/files/105/803/948/862/719/091/original/54e1cb7ca33ec449.png"],
          media_files: [{ file_size: 363_261 }]
        )
      end

      context "a new baraag image url" do
        strategy_should_work(
          "https://media.baraag.net/media_attachments/files/105/803/948/862/719/091/original/54e1cb7ca33ec449.png",
          image_urls: ["https://media.baraag.net/media_attachments/files/105/803/948/862/719/091/original/54e1cb7ca33ec449.png"],
          media_files: [{ file_size: 363_261 }]
        )
      end

      context "a deleted or invalid source" do
        strategy_should_work(
          "https://baraag.net/@nonamethankswashere/12345678901234567890",
          profile_url: "https://baraag.net/@nonamethankswashere",
          username: "nonamethankswashere",
          deleted: true
        )
      end
    end

    context "generating page urls" do
      should "work" do
        assert_equal("https://pawoo.net/@evazion/19451018", Source::URL.page_url("https://pawoo.net/@evazion/19451018/"))
        assert_equal("https://pawoo.net/web/statuses/19451018", Source::URL.page_url("https://pawoo.net/web/statuses/19451018/favorites"))
        assert_equal("https://baraag.net/@bardbot/105732813175612920", Source::URL.page_url("https://baraag.net/@bardbot/105732813175612920/"))
      end

      should "handle inconvertible urls" do
        assert_nil(Source::URL.page_url("https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png"))
        assert_nil(Source::URL.page_url("https://pawoo.net/@evazion/media"))
        assert_nil(Source::URL.page_url("https://media.baraag.net/media_attachments/files/105/732/803/241/495/700/original/556e1eb7f5ca610f.png"))
      end
    end

    should "Parse Pawoo URLs correctly" do
      assert(Source::URL.image_url?("https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png"))
      assert(Source::URL.image_url?("https://pawoo.net/media/lU2uV7C1MMQSb1czwvg"))

      assert(Source::URL.page_url?("https://pawoo.net/@evazion/19451018"))
      assert(Source::URL.page_url?("https://pawoo.net/web/statuses/19451018"))

      assert(Source::URL.profile_url?("https://pawoo.net/@evazion"))
      assert(Source::URL.profile_url?("https://pawoo.net/users/esoraneko"))
      assert(Source::URL.profile_url?("https://pawoo.net/web/accounts/47806"))
    end

    should "Parse Baraag URLs correctly" do
      assert(Source::URL.image_url?("https://baraag.net/system/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4"))
      assert(Source::URL.image_url?("https://media.baraag.net/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4"))

      assert(Source::URL.page_url?("https://baraag.net/@curator/102270656480174153"))
      assert(Source::URL.page_url?("https://baraag.net/web/statuses/102270656480174153"))

      assert(Source::URL.profile_url?("https://baraag.net/@danbooru"))
      assert(Source::URL.profile_url?("https://baraag.net/@web/danbooru"))
      assert(Source::URL.profile_url?("https://baraag.net/web/accounts/107862785324786980"))
    end
  end
end
