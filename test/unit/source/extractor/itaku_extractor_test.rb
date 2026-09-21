require "test_helper"

module Source::Tests::Extractor
  class ItakuExtractorTest < ActiveSupport::ExtractorTestCase
    context "A Itaku sample image URL" do
      strategy_should_work(
        "https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB/xl.jpg",
        image_urls: %w[https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png],
        media_files: [{ file_size: 50_948 }],
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Itaku full image URL" do
      strategy_should_work(
        "https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png",
        image_urls: %w[https://itaku.ee/api/media/gallery_imgs/IMG_2679_3GtFUgB.png],
        media_files: [{ file_size: 50_948 }],
        page_url: nil,
        profile_url: nil,
        display_name: nil,
        username: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Itaku /images/:id post" do
      strategy_should_work(
        "https://itaku.ee/images/812661",
        image_urls: %w[https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA.png],
        media_files: [{ file_size: 8_140_744 }],
        page_url: "https://itaku.ee/images/812661",
        published_at: Time.parse("2024-04-22T12:56:28.013302Z"),
        updated_at: nil,
        profile_url: "https://itaku.ee/velox",
        profile_urls: %w[https://itaku.ee/velox],
        display_name: "Velox",
        username: "velox",
        other_names: ["Velox"],
        tags: [
          ["cream_fur", "https://itaku.ee/home/images?tags=cream_fur"],
          ["white_hair", "https://itaku.ee/home/images?tags=white_hair"],
          ["casual_clothes", "https://itaku.ee/home/images?tags=casual_clothes"],
          ["eeveelution", "https://itaku.ee/home/images?tags=eeveelution"],
          ["whiskers", "https://itaku.ee/home/images?tags=whiskers"],
          ["eyes", "https://itaku.ee/home/images?tags=eyes"],
          ["heterochromia", "https://itaku.ee/home/images?tags=heterochromia"],
          ["hair", "https://itaku.ee/home/images?tags=hair"],
          ["fur", "https://itaku.ee/home/images?tags=fur"],
          ["blue_eyes", "https://itaku.ee/home/images?tags=blue_eyes"],
          ["furry", "https://itaku.ee/home/images?tags=furry"],
          ["fluffy_tail", "https://itaku.ee/home/images?tags=fluffy_tail"],
          ["video_game", "https://itaku.ee/home/images?tags=video_game"],
          ["game", "https://itaku.ee/home/images?tags=game"],
          ["hoodie", "https://itaku.ee/home/images?tags=hoodie"],
          ["velox_(character)", "https://itaku.ee/home/images?tags=velox_(character)"],
          ["pokemon_(species)", "https://itaku.ee/home/images?tags=pokemon_(species)"],
          ["pokemon", "https://itaku.ee/home/images?tags=pokemon"],
          ["collar", "https://itaku.ee/home/images?tags=collar"],
          ["gen_1_pokemon", "https://itaku.ee/home/images?tags=gen_1_pokemon"],
          ["hat", "https://itaku.ee/home/images?tags=hat"],
          ["pink_eyes", "https://itaku.ee/home/images?tags=pink_eyes"],
          ["jolteon", "https://itaku.ee/home/images?tags=jolteon"],
          ["nintendo", "https://itaku.ee/home/images?tags=nintendo"],
        ],
        dtext_artist_commentary_title: "Cool vibes",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Commission by @/yorozu1217 on Twitter
        EOS
      )
    end

    context "A Itaku /images/:id video post" do
      strategy_should_work(
        "https://itaku.ee/images/525359",
        image_urls: %w[https://itaku.ee/api/media/gallery_vids/Final_16-9_ckftagX.mp4],
        media_files: [{ file_size: 9_065_057 }],
        page_url: "https://itaku.ee/images/525359",
        profile_url: "https://itaku.ee/advosart",
        profile_urls: %w[https://itaku.ee/advosart],
        display_name: "Advos",
        username: "advosart",
        other_names: ["Advos", "advosart"],
        tags: [
          ["breakdance", "https://itaku.ee/home/images?tags=breakdance"],
          ["animation", "https://itaku.ee/home/images?tags=animation"],
          ["video", "https://itaku.ee/home/images?tags=video"],
          ["ratchet_and_clank", "https://itaku.ee/home/images?tags=ratchet_and_clank"],
          ["art", "https://itaku.ee/home/images?tags=art"],
        ],
        dtext_artist_commentary_title: "Ratchet's Breakdancing Skills",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          https://youtu.be/BwfZ_h22d3U
        EOS
      )
    end

    context "A Itaku /posts/:id post" do
      strategy_should_work(
        "https://itaku.ee/posts/130073",
        image_urls: %w[
          https://itaku.ee/api/media_2/gallery_imgs/1869351-1.output_1VWokMA.png
          https://itaku.ee/api/media_2/gallery_imgs/1846483-1.output_OhAApJ4.png
          https://itaku.ee/api/media_2/gallery_imgs/kf0212_Q7Z3jzR.png
          https://itaku.ee/api/media_2/gallery_imgs/1846409-1.output_WC5Md5Y.png
        ],
        media_files: [
          { file_size: 8_140_744 },
          { file_size: 1_148_847 },
          { file_size: 572_981 },
          { file_size: 3_473_969 },
        ],
        page_url: "https://itaku.ee/posts/130073",
        published_at: Time.parse("2024-04-22T12:56:30.102999Z"),
        updated_at: nil,
        profile_url: "https://itaku.ee/velox",
        profile_urls: %w[https://itaku.ee/velox],
        display_name: "Velox",
        username: "velox",
        other_names: ["Velox"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Itaku /commissions/:id page" do
      strategy_should_work(
        "https://itaku.ee/commissions/1755",
        image_urls: %w[
          https://itaku.ee/api/media_2/gallery_imgs/3_%D1%81%D0%BB%D0%BE%D1%82%D0%B0_%D0%BF%D0%BE_50_qj8JuBR.png
          https://itaku.ee/api/media_2/gallery_imgs/3_%D1%81%D0%BB%D0%BE%D1%82%D0%B0_%D0%BF%D0%BE_50_14_1_AXrYDqn.png
        ],
        media_files: [
          { file_size: 4_512_526 },
          { file_size: 9_824_767 },
        ],
        page_url: "https://itaku.ee/commissions/1755",
        published_at: Time.parse("2024-02-27T20:33:41.780389Z"),
        updated_at: Time.parse("2024-02-27T20:57:21.080403Z"),
        profile_url: "https://itaku.ee/kardamoni",
        profile_urls: %w[https://itaku.ee/kardamoni],
        display_name: "kardamoni",
        username: "kardamoni",
        other_names: ["kardamoni"],
        tags: [
          ["sea", "https://itaku.ee/home/images?tags=sea"],
          ["furry", "https://itaku.ee/home/images?tags=furry"],
          ["male", "https://itaku.ee/home/images?tags=male"],
          ["anthro", "https://itaku.ee/home/images?tags=anthro"],
          ["human", "https://itaku.ee/home/images?tags=human"],
          ["female", "https://itaku.ee/home/images?tags=female"],
          ["canine", "https://itaku.ee/home/images?tags=canine"],
          ["beach", "https://itaku.ee/home/images?tags=beach"],
          ["any_species", "https://itaku.ee/home/images?tags=any_species"],
          ["any_gender", "https://itaku.ee/home/images?tags=any_gender"],
          ["feline", "https://itaku.ee/home/images?tags=feline"],
        ],
        dtext_artist_commentary_title: "Lustrous Beach YCH",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Hello everyone~

          I'm new to this place but I'm doing YCHs and commissions for almost two years already on FFA c:

          Contains completed artwork~

          So this is my 1st YCH here!
          Price 50 USD!

          Rules:
          Any gender
          Any species
          Can draw pregnancy c:
          Buyer can choose both characters.

          Payment details:
          Payment through Paypal!
          Payment must be sent within 48 hours~

          TOS and more gallery - https://kardamoni.carrd.co/
        EOS
      )
    end

    context "A deleted or nonexistent Itaku image" do
      strategy_should_work(
        "https://itaku.ee/images/999999999",
        image_urls: [],
        page_url: "https://itaku.ee/images/999999999",
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        other_names: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
