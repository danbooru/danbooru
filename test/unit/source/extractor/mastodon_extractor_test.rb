require "test_helper"

module Source::Tests::Extractor
  class MastodonExtractorTest < ActiveSupport::ExtractorTestCase
    context "For Pawoo," do
      setup do
        skip "Pawoo keys not set" unless SiteCredential.for_site("Pawoo").present?
      end

      context "a https://pawoo.net/web/status/$id url" do
        strategy_should_work(
          "https://pawoo.net/web/statuses/1202176",
          image_urls: ["https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png"],
          profile_url: "https://pawoo.net/@9ed00e924818",
          username: "9ed00e924818",
          display_name: nil,
          published_at: Time.parse("2017-04-17T20:43:37.620000Z"),
          updated_at: nil,
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
          published_at: Time.parse("2017-06-10T23:02:48.412000Z"),
          updated_at: nil,
          tags: %w[foo bar baz],
          dtext_artist_commentary_desc: desc,
        )
      end

      context "a https://img.pawoo.net/ url" do
        strategy_should_work(
          "https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4",
          image_urls: ["https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4"],
          media_files: [{ file_size: 59_950 }],
          referer: "https://pawoo.net/@evazion/19451018",
          page_url: "https://pawoo.net/@evazion/19451018",
          published_at: nil,
          updated_at: nil,
        )
      end

      context "a deleted or invalid source" do
        strategy_should_work(
          "https://pawoo.net/@nonamethankswashere/12345678901234567890",
          profile_url: "https://pawoo.net/@nonamethankswashere",
          username: "nonamethankswashere",
          published_at: nil,
          updated_at: nil,
          deleted: true,
        )
      end
    end

    context "A status whose API returns an HTML page instead of JSON" do
      should "not raise an error" do
        Source::Extractor::Mastodon.any_instance.stubs(:parsed_get).returns(Nokogiri::HTML5.parse("<html><title>Error</title></html>"))
        extractor = Source::Extractor.find("https://pawoo.net/@evazion/19451018")

        assert_equal("evazion", extractor.username)
        assert_equal("https://pawoo.net/@evazion/19451018", extractor.page_url)
        assert_equal(["https://pawoo.net/@evazion"], extractor.profile_urls)
        assert_equal([], extractor.image_urls)
      end
    end
  end
end
