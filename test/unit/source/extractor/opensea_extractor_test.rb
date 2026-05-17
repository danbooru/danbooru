require "test_helper"

module Source::Tests::Extractor
  class OpenseaExtractorTest < ActiveSupport::ExtractorTestCase
    context "An Opensea sample image URL" do
      strategy_should_work(
        "https://i2c.seadn.io/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/61c60eeae8d8b9bccb53223b1c4d1f/9361c60eeae8d8b9bccb53223b1c4d1f.jpeg?w=1000",
        image_urls: %w[https://raw2.seadn.io/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/61c60eeae8d8b9bccb53223b1c4d1f/9361c60eeae8d8b9bccb53223b1c4d1f.jpeg],
        media_files: [{ file_size: 1_186_411 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An Opensea ethereum post" do
      strategy_should_work(
        "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861",
        image_urls: %w[https://raw2.seadn.io/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/783eecd8fe6016d909324b48df5c9b/c6783eecd8fe6016d909324b48df5c9b.jpeg],
        media_files: [{ file_size: 2_965_837 }],
        page_url: "https://opensea.io/item/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861",
        profile_urls: %w[https://opensea.io/Lusan666 https://opensea.io/0x697941341f8e6729da58b5f0c3447e142d970922],
        display_name: nil,
        username: "Lusan666",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "Black cat - Levana",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Happy Black Cat Appreciation Day!!

          Here's your black cat. She's a little fierce, be careful
        EOS
      )
    end

    context "An Opensea matic post" do
      strategy_should_work(
        "https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713",
        image_urls: %w[https://raw2.seadn.io/polygon/0x2953399124f0cbb46d2cbacd8a89cf0599974963/60ac5cfa50830e8ae998df54ec3652/a160ac5cfa50830e8ae998df54ec3652.png],
        media_files: [{ file_size: 45_706 }],
        page_url: "https://opensea.io/item/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713",
        profile_urls: %w[https://opensea.io/hebitsukai https://opensea.io/0xa2345a7139b18e57f1fd5ea27c87b51e09af241f],
        display_name: nil,
        username: "hebitsukai",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "mode",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          1/1 NFT 10000 x 7000 px PNG
        EOS
      )
    end

    context "An Opensea video post" do
      strategy_should_work(
        "https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/36019834214304435122883776814468417387629241948867352800925243912165007556609",
        image_urls: %w[https://raw2.seadn.io/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/e1e33ca7ec81c4c49be690c96e29da/c8e1e33ca7ec81c4c49be690c96e29da.mp4],
        media_files: [{ file_size: 43_195_672 }],
        page_url: "https://opensea.io/item/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/36019834214304435122883776814468417387629241948867352800925243912165007556609",
        profile_urls: %w[https://opensea.io/Bear_witch https://opensea.io/0x4fa280f224f6e5528ecae02f979cee2aad949d73],
        display_name: nil,
        username: "Bear_witch",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "HanumanWarrior02",
        dtext_artist_commentary_desc: "HanumanWarrior02",
      )
    end

    context "An Opensea post with a short token id" do
      strategy_should_work(
        "https://opensea.io/assets/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/8",
        image_urls: %w[https://raw2.seadn.io/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/48c0ba83437b1244db84cbea885f5dfb.png],
        media_files: [{ file_size: 2_027_082 }],
        page_url: "https://opensea.io/item/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/8",
        profile_urls: %w[https://opensea.io/Elina_E2n04n https://opensea.io/0x7c01a933e8761ddf96c2322c772fbd2527ded439],
        display_name: nil,
        username: "Elina_E2n04n",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "願いを叶える使者",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          モチーフ：七夕（主に短冊）
          上着は織姫のストールを意識してデザインしました。
        EOS
      )
    end

    context "A deleted or nonexistent Opensea post" do
      strategy_should_work(
        "https://opensea.io/assets/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/999999",
        image_urls: [],
        page_url: "https://opensea.io/item/ethereum/0xe07b8409130c8ca1548c16cf43d612c3a099e1f7/999999",
        profile_urls: [],
        display_name: nil,
        username: nil,
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
