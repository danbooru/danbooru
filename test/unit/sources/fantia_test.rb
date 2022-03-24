require "test_helper"

module Sources
  class FantiaTest < ActiveSupport::TestCase
    def setup
      super
      skip "session_id cookie not set" unless Danbooru.config.fantia_session_id.present?
    end

    context "A c.fantia.jp/uploads/post/file/ url" do
      should "work" do
        url = "https://c.fantia.jp/uploads/post/file/1070093/16faf0b1-58d8-4aac-9e86-b243063eaaf1.jpeg"
        source = Source::Extractor.find(url)

        assert_equal([url], source.image_urls)
        assert_equal("豆ラッコ", source.other_names.first)
        assert_equal("https://fantia.jp/fanclubs/27264", source.profile_url)
        assert_equal("https://fantia.jp/posts/1070093", source.page_url)
        assert_equal([], source.tags)
        assert_equal("大きく育った心春ちゃん1", source.artist_commentary_title)
        assert_equal("色々やります", source.artist_commentary_desc)
        assert_downloaded(3_692_131, url)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A c.fantia.jp/uploads/post_content_photo/ url" do
      should "work" do
        url = "https://cc.fantia.jp/uploads/post_content_photo/file/7087182/main_7f04ff3c-1f08-450f-bd98-796c290fc2d1.jpg?Key-Pair-Id=APKAIOCKYZS7WKBB6G7A&Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9jYy5mYW50aWEuanAvdXBsb2Fkcy9wb3N0X2NvbnRlbnRfcGhvdG8vZmlsZS83MDg3MTgyL21haW5fN2YwNGZmM2MtMWYwOC00NTBmLWJkOTgtNzk2YzI5MGZjMmQxLmpwZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTY0NjkyODAzN319fV19&Signature=wl2Nr9i1O5R5dDc7FB-8CKtRvyZPS6ZEFXn7Q74rBh9R2PZkpKuQUDDsJubgkYaHrqHEapcOdZczzZaM5kbRLXGPOnVFUE7vHKnXZTO~Z1-Z8Cqt823NKCR-AXBjYPhQoGP0pITLYkjhofy0FXg6RYJ0oNJPdKkdjcnwzr-nZfyaFgkrrQ5~LRDhW5HOgSNfvhJleMRLRgLtXbbgNnVwHmpFWNkFSwwmDcUTXTh4hrhQrOJ~xJmiQesSP1wPAE5ZZSBGsbUstOa5Y1nVu540wItR4VWLm-jjuMk9OIr-Nvxg0ocoP9WU13WrRbeMeL5X0xhxBYSxgVIKXko2BqMf5w__"
        ref = "https://fantia.jp/posts/1132267"
        source = Source::Extractor.find(url, ref)

        assert_equal("稲光伸二", source.other_names.first)
        assert_equal("https://fantia.jp/fanclubs/1096", source.profile_url)
        assert_equal(ref, source.page_url)
        assert_equal(["オリジナル", "漫画"], source.tags.map(&:first))
        assert_equal("黒い歴史(5)", source.artist_commentary_title)
        assert_match(/^この回から絵はほとんど今と/, source.artist_commentary_desc)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A c.fantia.jp/uploads/product/image/ url" do
      should "work" do
        url = "https://c.fantia.jp/uploads/product/image/249638/fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg"
        source = Source::Extractor.find(url)
        tags = ["イラスト集", "CG集", "PNG", "オリジナル", "宮前詩帆", "春川朱璃愛", "夏川黒羽", "ASMR", "音声", "原神", "シニョーラ"]

        assert_equal([url], source.image_urls)
        assert_match(/電波暗室/, source.other_names.first)
        assert_equal("https://fantia.jp/fanclubs/7", source.profile_url)
        assert_equal("https://fantia.jp/products/249638", source.page_url)
        assert_equal(tags, source.tags.map(&:first))
        assert_equal("2021年9月更新分[PNG] - September 2021", source.artist_commentary_title)
        assert_match(/This is the same as the image data updated in September 2021/, source.artist_commentary_desc)
        assert_downloaded(288_801, url)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A c.fantia.jp/uploads/product_image/file sample url" do
      should "work" do
        url = "https://c.fantia.jp/uploads/product_image/file/219407/main_bd7419c2-2450-4c53-a28a-90101fa466ab.jpg"
        ref = "https://fantia.jp/products/249638"
        source = Source::Extractor.find(url, ref)

        assert_equal(["https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg"], source.image_urls)
        assert_equal("https://fantia.jp/fanclubs/7", source.profile_url)
        assert_equal("https://fantia.jp/products/249638", source.page_url)
        assert_equal("2021年9月更新分[PNG] - September 2021", source.artist_commentary_title)
        assert_downloaded(613_103, url)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A fantia.jp/posts/$id/download url" do
      should "work" do
        url = "https://fantia.jp/posts/1143951/download/1830956"
        source = Source::Extractor.find(url)

        assert_match(%r{1830956/cbcdfcbe_20220224_120_040_100.png}, source.image_urls.sole)
        assert_equal("松永紅葉", source.other_names.first)
        assert_equal("https://fantia.jp/fanclubs/322", source.profile_url)
        assert_equal("https://fantia.jp/posts/1143951", source.page_url)
        assert_equal([], source.tags)
        assert_equal("今日の一枚3186 (1:20+0:40+1:00)", source.artist_commentary_title)
        assert_equal("今日の一枚3186 (1:20+0:40+1:00)", source.artist_commentary_desc)
        assert_downloaded(14_371_816, url)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A fantia.jp/posts/$id url" do
      should "work" do
        url = "https://fantia.jp/posts/1143951"
        source = Source::Extractor.find(url)

        assert_equal("https://c.fantia.jp/uploads/post/file/1143951/47491020-a6c6-47db-b09e-815b0530c0bc.png", source.image_urls.first)
        assert_match(%r{1830956/cbcdfcbe_20220224_120_040_100.png}, source.image_urls.second)
        assert_equal("松永紅葉", source.other_names.first)
        assert_equal("https://fantia.jp/fanclubs/322", source.profile_url)
        assert_equal("https://fantia.jp/posts/1143951", source.page_url)
        assert_equal([], source.tags)
        assert_equal("今日の一枚3186 (1:20+0:40+1:00)", source.artist_commentary_title)
        assert_equal("今日の一枚3186 (1:20+0:40+1:00)", source.artist_commentary_desc)
        assert_downloaded(1_157_953, source.image_urls[0])
        assert_downloaded(14_371_816, source.image_urls[1])
        assert_nothing_raised { source.to_h }
      end
    end

    context "A fantia.jp/products/$id url" do
      should "work" do
        url = "https://fantia.jp/products/249638"
        source = Source::Extractor.find(url)
        image_urls = %w[
          https://c.fantia.jp/uploads/product/image/249638/fd5aef8f-c217-49d0-83e8-289efb33dfc4.jpg
          https://c.fantia.jp/uploads/product_image/file/219406/c73bd7f9-a13a-48f7-9ac7-35309faa88c3.jpg
          https://c.fantia.jp/uploads/product_image/file/219407/bd7419c2-2450-4c53-a28a-90101fa466ab.jpg
          https://c.fantia.jp/uploads/product_image/file/219408/50aae3fd-11c5-4679-a584-e4276617d4b9.jpg
          https://c.fantia.jp/uploads/product_image/file/219409/1e777b93-2672-4a5d-8076-91b3766d3664.jpg
        ]

        assert_equal(image_urls, source.image_urls)
        assert_equal("https://fantia.jp/fanclubs/7", source.profile_url)
        assert_equal("https://fantia.jp/products/249638", source.page_url)

        assert_downloaded(288_801, source.image_urls[0])
        assert_downloaded(515_598, source.image_urls[1])
        assert_downloaded(613_103, source.image_urls[2])
        assert_downloaded(146_837, source.image_urls[3])
        assert_downloaded(78_316, source.image_urls[4])

        assert_nothing_raised { source.to_h }
      end
    end

    context "A product url with no images" do
      should "not get placeholder images" do
        source = Source::Extractor.find("https://fantia.jp/products/10000")
        assert_equal([], source.image_urls)
        assert_nothing_raised { source.to_h }
      end
    end

    context "A deleted or non-existing fantia url" do
      should "work" do
        url1 = "https://fantia.jp/posts/12345678901234567890"
        url2 = "https://fantia.jp/products/12345678901234567890"

        source1 = Source::Extractor.find(url1)
        source2 = Source::Extractor.find(url2)

        assert_equal([], source1.image_urls)
        assert_equal([], source2.image_urls)
        assert_nothing_raised { source1.to_h }
        assert_nothing_raised { source2.to_h }
      end
    end
  end
end
