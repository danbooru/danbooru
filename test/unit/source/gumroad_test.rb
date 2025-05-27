require 'test_helper'

module Sources
  class GumroadTest < ActiveSupport::TestCase
    context "Gumroad:" do
      context "A Gumroad product page url" do
        strategy_should_work(
          "https://movw2000.gumroad.com/l/zbslv",
          page_url: "https://movw2000.gumroad.com/l/zbslv",
          image_urls: %w[
            https://public-files.gumroad.com/3eqnyzi5re6omz9wrb0vv1tmom07
            https://public-files.gumroad.com/6hbo93vnwie3ff26u5f4t6bnksm4
            https://public-files.gumroad.com/tjnxl43or05w21qxs5t9943hdnc7
            https://public-files.gumroad.com/fxm3kt4eid34gci7609o8p1ye4ul
            https://public-files.gumroad.com/e7o41pzpc3olkgj7gfpr2ti2xoak
            https://public-files.gumroad.com/gqyzozjyiewftupi0bgycs3de9m5
          ],
          profile_url: "https://movw2000.gumroad.com",
          display_name: "DAKO",
          username: "movw2000",
          tag_name: "movw2000",
          other_names: ["DAKO", "movw2000"],
          tags: [],
          artist_commentary_title: "2022/02 PATREON REWARD：18++ Tier",
          dtext_artist_commentary_desc: <<~EOS.chomp
            jpg x 25

            psd x 5

            wip psd x2 , mp4 x 1

            animation gif x 2 , mp4 x 2
          EOS
        )
      end

      context "A Gumroad product image url without referer" do
        strategy_should_work(
          "https://public-files.gumroad.com/variants/6hbo93vnwie3ff26u5f4t6bnksm4/baaca0eb0e33dc4f9d45910b8c86623f0144cea0fe0c2093c546d17d535752eb",
          image_urls: ["https://public-files.gumroad.com/6hbo93vnwie3ff26u5f4t6bnksm4"],
          media_files: [{ file_size: 859_625 }],
          page_url: nil,
          profile_url: nil,
          display_name: nil,
          username: nil,
          tags: [],
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: "",
        )
      end

      context "A Gumroad product image url with referer" do
        strategy_should_work(
          "https://public-files.gumroad.com/variants/6hbo93vnwie3ff26u5f4t6bnksm4/baaca0eb0e33dc4f9d45910b8c86623f0144cea0fe0c2093c546d17d535752eb",
          referer: "https://movw2000.gumroad.com/l/zbslv",
          image_urls: ["https://public-files.gumroad.com/6hbo93vnwie3ff26u5f4t6bnksm4"],
          page_url: "https://movw2000.gumroad.com/l/zbslv",
          profile_url: "https://movw2000.gumroad.com",
          display_name: "DAKO",
          username: "movw2000",
          tag_name: "movw2000",
          other_names: ["DAKO", "movw2000"],
          tags: [],
          artist_commentary_title: "2022/02 PATREON REWARD：18++ Tier",
          dtext_artist_commentary_desc: <<~EOS.chomp
            jpg x 25

            psd x 5

            wip psd x2 , mp4 x 1

            animation gif x 2 , mp4 x 2
          EOS
        )
      end

      context "A Gumroad post page url" do
        strategy_should_work(
          "https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901",
          page_url: "https://movw2000.gumroad.com/p/new-product-b072093e-e628-4a92-9740-e9b4564d9901",
          image_urls: %w[
            https://public-files.gumroad.com/nztoa76lk2wahffodnxwhqh49tkq
            https://public-files.gumroad.com/2unbiv4p4gysgn1v3n5ah5f9ux9p
          ],
          profile_url: "https://movw2000.gumroad.com",
          display_name: "DAKO",
          username: "movw2000",
          tag_name: "movw2000",
          other_names: ["DAKO", "movw2000"],
          tags: [],
          artist_commentary_title: nil,
          dtext_artist_commentary_desc: <<~EOS.chomp
            2022 is coming to an end,

            and the products on gumroad will have a 20% discount from now until 12/31.

            Discount code : omuxoke
          EOS
        )
      end

      should "Parse Gumroad URLs correctly" do
        assert(Source::URL.image_url?("https://public-files.gumroad.com/zc2289rdv8fx905pgaikh40fsle2"))
        assert(Source::URL.image_url?("https://public-files.gumroad.com/variants/nsqiekm8gnl5nfrw3mtthminn2ig/e82ce07851bf15f5ab0ebde47958bb042197dbcdcae02aa122ef3f5b41e97c02"))

        assert(Source::URL.page_url?("https://aiki.gumroad.com/l/HelmV2T3?layout=profile"))
        assert(Source::URL.page_url?("https://gumroad.com/l/HelmV2T3?layout=profile"))
        assert(Source::URL.page_url?("https://www.gumroad.com/l/HelmV2T3?layout=profile"))

        assert(Source::URL.profile_url?("https://gumroad.com/aiki"))
        assert(Source::URL.profile_url?("https://www.gumroad.com/aiki"))
        assert(Source::URL.profile_url?("https://aiki.gumroad.com"))
      end
    end
  end
end
