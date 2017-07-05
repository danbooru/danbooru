require 'test_helper'

module Sources
  class NijieTest < ActiveSupport::TestCase
    context "The source site for a nijie page" do
      setup do
        @site = Sources::Site.new("http://nijie.info/view.php?id=213043")
        @site.get
      end

      should "get the image url" do
        assert_equal("https://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg", @site.image_url)
      end

      should "get the profile" do
        assert_equal("http://nijie.info/members.php?id=728995", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("莚", @site.artist_name)
      end

      should "get the tags" do
        assert_equal([["眼鏡", "http://nijie.info/search.php?word=%E7%9C%BC%E9%8F%A1"], ["リトルウィッチアカデミア", "http://nijie.info/search.php?word=%E3%83%AA%E3%83%88%E3%83%AB%E3%82%A6%E3%82%A3%E3%83%83%E3%83%81%E3%82%A2%E3%82%AB%E3%83%87%E3%83%9F%E3%82%A2"], ["アーシュラ先生", "http://nijie.info/search.php?word=%E3%82%A2%E3%83%BC%E3%82%B7%E3%83%A5%E3%83%A9%E5%85%88%E7%94%9F"]], @site.tags)
      end

      should "get the commentary" do
        title = "ジャージの下は"
        desc = "「リトルウィッチアカデミア」から無自覚サキュバスぶりを発揮するアーシュラ先生です"

        assert_equal(title, @site.artist_commentary_title)
        assert_equal(desc, @site.artist_commentary_desc)
      end
    end

    context "The source site for a nijie referer url" do
      setup do
        @site = Sources::Site.new("http://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg", referer_url: "https://nijie.info/view_popup.php?id=213043")
        @site.get
      end

      should "get the image url" do
        assert_equal("https://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg", @site.image_url)
      end

      should "get the profile" do
        assert_equal("http://nijie.info/members.php?id=728995", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("莚", @site.artist_name)
      end
    end

    context "The source site for a nijie popup" do
      setup do
        @site = Sources::Site.new("https://nijie.info/view_popup.php?id=213043")
        @site.get
      end

      should "get the image url" do
        assert_equal("https://pic03.nijie.info/nijie_picture/728995_20170505014820_0.jpg", @site.image_url)
      end

      should "get the profile" do
        assert_equal("http://nijie.info/members.php?id=728995", @site.profile_url)
      end

      should "get the artist name" do
        assert_equal("莚", @site.artist_name)
      end
    end

    context "The source site for a nijie gallery" do
      setup do
        @site = Sources::Site.new("http://nijie.info/view.php?id=218856")
        @site.get
      end

      should "get the image urls" do
        urls = %w[
          https://pic03.nijie.info/nijie_picture/236014_20170620101426_0.png
          https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png
          https://pic01.nijie.info/nijie_picture/diff/main/218856_1_236014_20170620101330.png
          https://pic01.nijie.info/nijie_picture/diff/main/218856_2_236014_20170620101331.png
          https://pic03.nijie.info/nijie_picture/diff/main/218856_3_236014_20170620101331.png
          https://pic03.nijie.info/nijie_picture/diff/main/218856_4_236014_20170620101333.png
        ]

        assert_equal(urls, @site.image_urls)
      end

      should "get the dtext-ified commentary" do
        desc = <<-EOS.strip_heredoc.chomp
          foo [b]bold[/b] [i]italics[/i] [s]strike[/s] red

          http://nijie.info/view.php?id=218944
        EOS

        assert_equal(desc, @site.dtext_artist_commentary_desc)
      end
    end
  end
end
