require 'test_helper'

module Sources
  class PawooTest < ActiveSupport::TestCase
    context "The source site for a https://pawoo.net/web/status/$id url" do
      setup do
        skip "Pawoo keys not set" unless Danbooru.config.pawoo_client_id
        @site = Sources::Strategies.find("https://pawoo.net/web/statuses/1202176")
      end

      should "get the profile" do
        assert_equal("https://pawoo.net/@9ed00e924818", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("9ed00e924818", @site.artist_name)
      end

      should "get the image url" do
        assert_equal("https://img.pawoo.net/media_attachments/files/000/128/953/original/4c0a06087b03343f.png", @site.image_url)
      end

      should "get the commentary" do
        desc = '<p>a mind forever voyaging through strange seas of thought alone <a href="https://pawoo.net/media/9hJzXvwxVl1CezW0ecM" rel="nofollow noopener" target="_blank"><span class="invisible">https://</span><span class="ellipsis">pawoo.net/media/9hJzXvwxVl1Cez</span><span class="invisible">W0ecM</span></a></p>'
        assert_equal(desc, @site.artist_commentary_desc)
      end

      should "get the dtext-ified commentary" do
        desc = 'a mind forever voyaging through strange seas of thought alone'
        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end

    context "The source site for a https://pawoo.net/$user/$id url" do
      setup do
        skip "Pawoo keys not set" unless Danbooru.config.pawoo_client_id
        @site = Sources::Strategies.find("https://pawoo.net/@evazion/19451018")
      end

      should "get the profile" do
        assert_equal("https://pawoo.net/@evazion", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("evazion", @site.artist_name)
      end

      should "get the image urls" do
        urls = %w[
          https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png
          https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4
          https://img.pawoo.net/media_attachments/files/001/298/081/original/2588ee9ba808f38f.webm
          https://img.pawoo.net/media_attachments/files/001/298/084/original/media.mp4
        ]

        assert_equal(urls, @site.image_urls)
      end

      should "get the tags" do
        assert_equal(%w[foo bar baz], @site.tags.map(&:first))
      end

      should "get the commentary" do
        desc = "<p>test post please ignore</p><p>blah blah blah</p><p>this is a test 🍕</p><p><a href=\"https://pawoo.net/tags/foo\" class=\"mention hashtag\" rel=\"tag\">#<span>foo</span></a> <a href=\"https://pawoo.net/tags/bar\" class=\"mention hashtag\" rel=\"tag\">#<span>bar</span></a> <a href=\"https://pawoo.net/tags/baz\" class=\"mention hashtag\" rel=\"tag\">#<span>baz</span></a></p>"

        assert_nil(@site.artist_commentary_title)
        assert_equal(desc, @site.artist_commentary_desc)
      end

      should "get the dtext-ified commentary" do
        desc = <<-EOS.strip_heredoc.chomp
          test post please ignore

          blah blah blah

          this is a test 🍕

          "#foo":[https://pawoo.net/tags/foo] "#bar":[https://pawoo.net/tags/bar] "#baz":[https://pawoo.net/tags/baz]
        EOS

        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end

    context "The source site for a https://img.pawoo.net/ url" do
      setup do
        skip "Pawoo keys not set" unless Danbooru.config.pawoo_client_id
        @url = "https://img.pawoo.net/media_attachments/files/001/298/028/original/55a6fd252778454b.mp4"
        @ref = "https://pawoo.net/@evazion/19451018"
        @site = Sources::Strategies.find(@url, @ref)
      end

      should "fetch the source data" do
        assert_equal("evazion", @site.artist_name)
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "https://pawoo.net/@evazion/19451018/"
        source2 = "https://pawoo.net/web/statuses/19451018/favorites"

        assert_equal("https://pawoo.net/@evazion/19451018", Sources::Strategies.normalize_source(source1))
        assert_equal("https://pawoo.net/web/statuses/19451018", Sources::Strategies.normalize_source(source2))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source1 = "https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png"
        bad_source2 = "https://pawoo.net/@evazion/media"

        assert_equal(bad_source1, Sources::Strategies.normalize_source(bad_source1))
        assert_equal(bad_source2, Sources::Strategies.normalize_source(bad_source2))
      end
    end
  end
end
