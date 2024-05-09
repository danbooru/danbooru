# frozen_string_literal: true

require "test_helper"

module Sources
  class OpenseaTest < ActiveSupport::TestCase
    context "Opensea:" do
      context "An Opensea /raw/ sample image URL" do
        strategy_should_work(
          "https://i.seadn.io/s/raw/files/473d8a4978c86ede320b8372dfe2a8b3.png?auto=format&dpr=1&w=384",
          image_urls: %w[https://i.seadn.io/s/raw/files/473d8a4978c86ede320b8372dfe2a8b3.png],
          media_files: [{ file_size: 52_000 }],
          page_url: nil
        )
      end

      context "An Opensea /gae/ sample image URL" do
        strategy_should_work(
          "https://i.seadn.io/gae/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA?auto=format&dpr=1&w=1000",
          image_urls: %w[https://lh3.googleusercontent.com/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA=d],
          media_files: [{ file_size: 1_186_411 }],
          page_url: nil
        )
      end

      context "An lh3.googleusercontent.com image URL with a Opensea referer" do
        strategy_should_work(
          "https://lh3.googleusercontent.com/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA=d",
          referer: "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/25498143383868488060407396481663496375452486694447065582311815598428410347521",
          image_urls: %w[https://lh3.googleusercontent.com/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA=d],
          media_files: [{ file_size: 1_186_411 }],
          page_url: "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/25498143383868488060407396481663496375452486694447065582311815598428410347521",
          profile_url: "https://opensea.io/tororotororo",
          profile_urls: %w[https://opensea.io/tororotororo https://opensea.io/0x385f700eb49ec720cdc1adc3d91e42cdf8325878],
          artist_name: "tororotororo",
          tag_name: "tororotororo",
          other_names: ["tororotororo"],
          tags: [],
          dtext_artist_commentary_title: "牛乳を飲む/Drink milk",
          dtext_artist_commentary_desc: ""
        )
      end

      context "An Opensea ethereum post" do
        strategy_should_work(
          "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861",
          image_urls: %w[https://openseauserdata.com/files/c6783eecd8fe6016d909324b48df5c9b.jpg],
          media_files: [{ file_size: 2_965_837 }],
          page_url: "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861",
          profile_url: "https://opensea.io/Lusan666",
          profile_urls: %w[https://opensea.io/Lusan666 https://opensea.io/0x697941341f8e6729da58b5f0c3447e142d970922],
          artist_name: "Lusan666",
          tag_name: "lusan666",
          other_names: ["Lusan666"],
          dtext_artist_commentary_title: "Black cat - Levana",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Happy Black Cat Appreciation Day!!

            Here's your black cat. She's a little fierce, be careful
          EOS
        )
      end

      context "An Opensea matic post" do
        strategy_should_work(
          "https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713",
          image_urls: %w[https://openseauserdata.com/files/070922161d3c4deab9f76263b3ce6018.png],
          media_files: [{ file_size: 5_623_570 }],
          page_url: "https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713",
          profile_url: "https://opensea.io/hebitsukai",
          profile_urls: %w[https://opensea.io/hebitsukai https://opensea.io/0xa2345a7139b18e57f1fd5ea27c87b51e09af241f],
          artist_name: "hebitsukai",
          tag_name: "hebitsukai",
          other_names: ["hebitsukai"],
          dtext_artist_commentary_title: "mode",
          dtext_artist_commentary_desc: <<~EOS.chomp
            1/1 NFT 10000 x 7000 px PNG
          EOS
        )
      end

      context "An Opensea video post" do
        strategy_should_work(
          "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/36019834214304435122883776814468417387629241948867352800925243912165007556609",
          image_urls: %w[https://openseauserdata.com/files/c8e1e33ca7ec81c4c49be690c96e29da.mp4],
          media_files: [{ file_size: 43_195_672 }],
          page_url: "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/36019834214304435122883776814468417387629241948867352800925243912165007556609",
          profile_url: "https://opensea.io/Bear_witch",
          profile_urls: %w[https://opensea.io/Bear_witch https://opensea.io/0x4fa280f224f6e5528ecae02f979cee2aad949d73],
          artist_name: "Bear_witch",
          tag_name: "bear_witch",
          other_names: ["Bear_witch"],
          dtext_artist_commentary_title: "HanumanWarrior02",
          dtext_artist_commentary_desc: "HanumanWarrior02"
        )
      end

      context "An Opensea post without an image" do
        strategy_should_work(
          "https://opensea.io/assets/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/8",
          image_urls: [],
          page_url: "https://opensea.io/assets/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/8",
          profile_url: "https://opensea.io/Elina_E2n04n",
          profile_urls: %w[https://opensea.io/Elina_E2n04n https://opensea.io/0x7c01a933e8761ddf96c2322c772fbd2527ded439],
          artist_name: "Elina_E2n04n",
          tag_name: "elina_e2n04n",
          other_names: ["Elina_E2n04n"],
          dtext_artist_commentary_title: "願いを叶える使者",
          dtext_artist_commentary_desc: <<~EOS.chomp
            モチーフ：七夕（主に短冊）
            上着は織姫のストールを意識してデザインしました。
          EOS
        )
      end

      context "A deleted or nonexistent Opensea post" do
        strategy_should_work(
          "https://opensea.io/assets/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/999999",
          image_urls: [],
          media_files: [],
          page_url: "https://opensea.io/assets/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/999999",
          profile_url: nil,
          profile_urls: %w[],
          artist_name: nil,
          tag_name: nil,
          other_names: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Opensea URLs correctly" do
        assert(Source::URL.image_url?("https://i.seadn.io/s/raw/files/473d8a4978c86ede320b8372dfe2a8b3.png?auto=format&dpr=1&w=384"))
        assert(Source::URL.image_url?("https://i.seadn.io/gae/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA?auto=format&dpr=1&w=1000"))

        assert(Source::URL.page_url?("https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713"))
        assert(Source::URL.page_url?("https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861"))

        assert(Source::URL.profile_url?("https://opensea.io/0x7C01A933e8761DDf96C2322c772FbD2527ded439"))
        assert(Source::URL.profile_url?("https://opensea.io/accounts/0xff605910dc69999dca1fe2fa289a43cc2d51f0fc"))
        assert(Source::URL.profile_url?("https://opensea.io/tororotororo"))
      end
    end
  end
end
