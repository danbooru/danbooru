require "test_helper"

module Source::Tests::Extractor
  class YoutubeExtractorTest < ActiveSupport::ExtractorTestCase
    context "A community post sample image URL" do
      strategy_should_work(
        "https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=s1600-rw-nd-v1",
        image_urls: %w[https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=d],
        media_files: [{ file_size: 4_346_136 }],
        page_url: nil,
      )
    end

    context "A community post full image URL" do
      strategy_should_work(
        "https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=d",
        image_urls: %w[https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=d],
        media_files: [{ file_size: 4_346_136 }],
        page_url: nil,
      )
    end

    context "A channel banner sample image URL" do
      strategy_should_work(
        "https://yt3.googleusercontent.com/NsA5K3ie2Xumot_5Eu-VUTG_v-xW5gKplU8aIBDyD0rGjtjzVWcjjG1zI7f0g3RtB-PzWW0s=w1060-fcrop64=1,00005a57ffffa5a8-k-c0xffffffff-no-nd-rj",
        image_urls: %w[https://yt3.googleusercontent.com/NsA5K3ie2Xumot_5Eu-VUTG_v-xW5gKplU8aIBDyD0rGjtjzVWcjjG1zI7f0g3RtB-PzWW0s=d],
        media_files: [{ file_size: 200_454 }],
        page_url: nil,
      )
    end

    context "A playlist album cover image URL with a playlist referer" do
      strategy_should_work(
        "https://lh3.googleusercontent.com/-o3R2xYfE_i2CnlCKGuGdd_l2etaZUHo-pWraD83isUZdkZpBhdAdt5Q7oQGsRf5TFHpnr2i1wD1YKLrgA=w544-h544-l90-rj",
        referer: "https://music.youtube.com/playlist?list=OLAK5uy_noU123lqMHztLaZkpu00qEBr0thoaq1c4",
        image_urls: %w[https://lh3.googleusercontent.com/-o3R2xYfE_i2CnlCKGuGdd_l2etaZUHo-pWraD83isUZdkZpBhdAdt5Q7oQGsRf5TFHpnr2i1wD1YKLrgA=d],
        media_files: [{ file_size: 4_329_101 }],
        page_url: "https://music.youtube.com/playlist?list=OLAK5uy_noU123lqMHztLaZkpu00qEBr0thoaq1c4",
      )
    end

    context "A community post with a single image" do
      strategy_should_work(
        "https://www.youtube.com/channel/UCykMWf8B8I7c_jA8FTy2tGw/community?lb=UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf",
        image_urls: %w[https://yt3.ggpht.com/4aUIQfric9Rg3xy5VqtwWCH6iZgVVKyMnsGJiVp7TQk166jKSSjTKgQyKVEgCz2bhGSAvG43fSgnrg=d],
        media_files: [{ file_size: 2_348_082 }],
        page_url: "https://www.youtube.com/post/UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf",
        profile_url: "https://www.youtube.com/@AmiyaAranha",
        profile_urls: %w[https://www.youtube.com/@AmiyaAranha https://www.youtube.com/channel/UCykMWf8B8I7c_jA8FTy2tGw],
        display_name: "Amiya Ch. アミヤ・アラニャ",
        username: "AmiyaAranha",
        tag_name: "amiyaaranha",
        other_names: ["Amiya Ch. アミヤ・アラニャ", "AmiyaAranha"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Present day.... Present time!! Nyehehhe
          Thanks for coming to the premiere! I am very happy with how things turned out!
          Art: @/in_NOCENT_
        EOS
      )
    end

    context "A community post with multiple images" do
      strategy_should_work(
        "https://www.youtube.com/post/UgkxBkJE1Eu_6S9sADZF5IuK5MPRSWf4VVz3",
        image_urls: %w[
          https://yt3.ggpht.com/m1k56DLAc8bruHhGpLDmc-idXUF-mjBxDItnBMYBlEGRt5Y5ApgTAFcAimu9w0Gdq7dFyA1L7SWqFDg=d
          https://yt3.ggpht.com/jmTsfA4yq-et_6fucgiSB8rWcPuGm_oyCZ1nuL1m2poU510DW4H0IHItXycmGNFpnUTL0vNeuSHZosk=d
          https://yt3.ggpht.com/HazeswOR3AKZiCLMV8cgkI7kQAV7PGKT3iy3wAbmptwSETaWpMbQDzFYTLR2RI-TBZYVtzX8B0TF=d
        ],
        media_files: [
          { file_size: 2_623_200 },
          { file_size: 656_633 },
          { file_size: 723_316 },
        ],
        page_url: "https://www.youtube.com/post/UgkxBkJE1Eu_6S9sADZF5IuK5MPRSWf4VVz3",
        profile_url: "https://www.youtube.com/@Mirae_Somang",
        profile_urls: %w[https://www.youtube.com/@Mirae_Somang https://www.youtube.com/channel/UCkoNwhfCPUiWbkmoUoa7XNg],
        display_name: "Mirae Somang",
        username: "Mirae_Somang",
        tag_name: "mirae_somang",
        other_names: ["Mirae Somang", "Mirae_Somang"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          안녕하세요. 미래소망입니다.

          이번에는 아야와 하타테가 등장하는 짧은 애니메이션이 가까운 시일에 공개됩니다.
          물론 '미움받는 요괴 PART 2'는 같이 작업하고 있으며 약속대로 12.25일에 업로드 될 거에요.

          그리고 저는 주말에 자전거를 타고 잠시 여행 좀 다녀 오겠습니다.
          (작품 콘티는 이미 다 짜놨어요~)

          갔다 와서 작업할게요. 그럼 나중에 봐요! :)

          ---

          Hi, I'm Mirae Somang.

          a short animation featuring Aya and Hatate will be released soon.
          Of course, working on 'A Hated Youkai PART 2' and it will be released on December 25th as promised.

          And I'm going to go on a short trip on my bike this weekend.
          (I already have the storyboard ready~)

          I'll work on it after travel over. See you later :)
        EOS
      )
    end

    context "A community post with hashtags and external links" do
      strategy_should_work(
        "https://www.youtube.com/post/UgkxPM838FMMDlZd0fooRblYR4zysjfbgYhv",
        image_urls: %w[https://yt3.ggpht.com/-e3T7-xK0aboSxZZpSI4fXnerhFCXbCuL96zPIXgDd4u43jLsaKi4PrkPDn3BRiRTVXzD_YBUoLlt50=d],
        media_files: [{ file_size: 1_379_490 }],
        page_url: "https://www.youtube.com/post/UgkxPM838FMMDlZd0fooRblYR4zysjfbgYhv",
        profile_urls: %w[https://www.youtube.com/@RitaKamishiro https://www.youtube.com/channel/UCBJFsaCvgBa1a9BnEaxu97Q],
        display_name: "Rita Kamishiro",
        username: "RitaKamishiro",
        tags: [
          ["kamiscribble", "https://www.youtube.com/hashtag/kamiscribble"],
          ["神スクリブル", "https://www.youtube.com/hashtag/神スクリブル"],
          ["rkangel", "https://www.youtube.com/hashtag/rkangel"],
          ["rkエンジェル", "https://www.youtube.com/hashtag/rkエンジェル"],
          ["kameme", "https://www.youtube.com/hashtag/kameme"],
          ["カミーム", "https://www.youtube.com/hashtag/カミーム"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          💠Weekly Schedule 5.20.2024💠
          My Mental Health Awareness Month 2024 event is this week! Be sure to join us for the panels and charity concert~

          🎨: <https://x.com/popopopopo623>
          Fanart: "#Kamiscribble":[https://www.youtube.com/hashtag/kamiscribble] "#神スクリブル":[https://www.youtube.com/hashtag/神スクリブル]
          Fandom: "#RKangel":[https://www.youtube.com/hashtag/rkangel] "#RKエンジェル":[https://www.youtube.com/hashtag/rkエンジェル]
          Memes: "#KaMEME":[https://www.youtube.com/hashtag/kameme] "#カミーム":[https://www.youtube.com/hashtag/カミーム]
        EOS
      )
    end

    # XXX Not supported.
    context "A Youtube video" do
      strategy_should_work(
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        image_urls: [],
        page_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        profile_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted or nonexistent community post" do
      strategy_should_work(
        "https://www.youtube.com/post/bad_id",
        image_urls: [],
        page_url: "https://www.youtube.com/post/bad_id",
        profile_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tag_name: nil,
        other_names: [],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
