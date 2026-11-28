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
        media_files: [{ file_size: 200_418 }],
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
        media_files: [{ file_size: 2_348_075 }],
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
          { file_size: 2_623_193 },
          { file_size: 656_626 },
          { file_size: 723_309 },
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

    context "A Youtube video with hashtags, mentions, and external links" do
      strategy_should_work(
        "https://www.youtube.com/watch?v=YZV4d6Ssqdo",
        image_urls: [],
        page_url: "https://www.youtube.com/watch?v=YZV4d6Ssqdo",
        profile_url: "https://www.youtube.com/@ilekkim",
        profile_urls: %w[https://www.youtube.com/@ilekkim https://www.youtube.com/channel/UCl8FRguXVySAHDnKdqn3QOg],
        display_name: "ilekkim",
        username: "ilekkim",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["hololive", "https://www.youtube.com/hashtag/hololive"],
          ["hololiveenglish", "https://www.youtube.com/hashtag/hololiveenglish"],
          ["gigimurin", "https://www.youtube.com/hashtag/gigimurin"],
          ["hololiveen", "https://www.youtube.com/hashtag/hololiveen"],
        ],
        dtext_artist_commentary_title: "Gigi Remembers【Hololive Animation】",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          based on true events that happens during September 21st

          inspired by
          "@vensen5150":[https://www.youtube.com/@vensen5150]
          "@themathewflames":[https://www.youtube.com/@themathewflames]
          "@ColonelFanzipantzen":[https://www.youtube.com/@ColonelFanzipantzen]
          check out their amazing work its very cool and inspiring

          Models:
          Gigi @morandoblend
          Cece, Liz & IRyS @sunekosurisuri_
          Raora @syn0104
          Mori @genoge_cg
          Ina @tihi_a
          Bae @antro3dcg
          mmd.hololive.tv
          Hololive Office by @plum_wine_053
          Amelia Chibi @Om Abhyankar on sketchfab
          bloop @ayaelghan on sketchfab
          HoloCouncil Plushies @Seafoam on sketchfab
          Other assets and environments from sketchfab
          Made in Goo Engine 4.2
          Edited on Davinci Resolve
          Music: "September" by Earth, Wind and Fire

          Follow me on X/Twitter: <https://x.com/ilekkim>
          Support me: <https://ko-fi.com/ilekkim>

          Check the tubers in this video out!
          "@holoen_gigimurin":[https://www.youtube.com/@holoen_gigimurin], "@holoen_ceciliaimmergreen":[https://www.youtube.com/@holoen_ceciliaimmergreen], "@holoen_raorapanthera":[https://www.youtube.com/@holoen_raorapanthera],"@holoen_erbloodflame":[https://www.youtube.com/@holoen_erbloodflame], "@NerissaRavencroft":[https://www.youtube.com/@NerissaRavencroft], "@KosekiBijou":[https://www.youtube.com/@KosekiBijou], "@ShioriNovella":[https://www.youtube.com/@ShioriNovella], "@FUWAMOCOch":[https://www.youtube.com/@FUWAMOCOch], "@NinomaeInanis":[https://www.youtube.com/@NinomaeInanis], "@TakanashiKiara":[https://www.youtube.com/@TakanashiKiara], "@MoriCalliope":[https://www.youtube.com/@MoriCalliope], "@IRyS":[https://www.youtube.com/@IRyS], "@HakosBaelz":[https://www.youtube.com/@HakosBaelz] & "@OuroKronii":[https://www.youtube.com/@OuroKronii]

          This is a fan-made animation. I do not own the music or the characters. All rights belong to their respective owners. Please support the original creators!

          yipeee new video! i know theres alot of cleaning up i could've done but i was already late for when i wanted to post this because not only was i busy settling in my new place but also got sick when i first arrived. but anyways this one i really wanted to practice and not rely 100% on references on some scenes because i felt like i was only copying references 1 to 1, especially in acting and expressions i feel very bad at it. though ngl i still feel like im copying references w this one buuuuut whatever. also was itching to do actions scenes so i sneaked some there. i also couldve fixed the positions a little bit with everyone dancing cuz it looks too spacious but my laptops memory was leaking w everyones model in the scene (rip laptop). and at the end i also planned to do a proper dance for Kronii but her rig was broken so i tried to hide it instead lmao. anw thank you so much for the recent support it really motivates me to learn more and share my work w u guys!! also opening up to be a freelance animator or accepting commissions if anyones interested feel free to dm me on X or email me link in my bio!
          (post upload) some people have been mentioning it and I have came to realize that IRyS's pants somehow didn't render and she looks unclothed. But I promise you she is wearing something under there. It was my mistake for not noticing, apologies for that.

          "#hololive":[https://www.youtube.com/hashtag/hololive] "#hololiveenglish":[https://www.youtube.com/hashtag/hololiveenglish] "#gigimurin":[https://www.youtube.com/hashtag/gigimurin] "#hololiveen":[https://www.youtube.com/hashtag/hololiveen]
        EOS
      )
    end

    context "A Youtube short" do
      strategy_should_work(
        "https://www.youtube.com/shorts/GSR2ghvoTDY",
        image_urls: [],
        page_url: "https://www.youtube.com/watch?v=GSR2ghvoTDY",
        profile_url: "https://www.youtube.com/@BlueSechi",
        profile_urls: %w[https://www.youtube.com/@BlueSechi https://www.youtube.com/channel/UCOvfZCGGft-KwjVh7XihUOg],
        display_name: "BlueSechi",
        username: "BlueSechi",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["bluesechi", "https://www.youtube.com/hashtag/bluesechi"],
          ["ブルーセチ", "https://www.youtube.com/hashtag/ブルーセチ"],
          ["フリーレン", "https://www.youtube.com/hashtag/フリーレン"],
        ],
        dtext_artist_commentary_title: "フリーレンやめろ!!  #bluesechi #フリーレン #ブルーセチ",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Twitter : <https://twitter.com/sechihyeo>
          Twitch : <https://twitch.tv/nunggom>
          "#bluesechi":[https://www.youtube.com/hashtag/bluesechi] "#ブルーセチ":[https://www.youtube.com/hashtag/ブルーセチ] "#フリーレン":[https://www.youtube.com/hashtag/フリーレン]
        EOS
      )
    end

    context "A deleted or nonexistent Youtube video" do
      strategy_should_work(
        "https://www.youtube.com/watch?v=aaaaaaaaaaa",
        image_urls: [],
        page_url: "https://www.youtube.com/watch?v=aaaaaaaaaaa",
        profile_url: nil,
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

    context "A Youtube video with an English title and description that's auto-translated in other languages" do
      strategy_should_work(
        "https://www.youtube.com/watch?v=rMzdv7al7bU",
        image_urls: [],
        page_url: "https://www.youtube.com/watch?v=rMzdv7al7bU",
        profile_url: "https://www.youtube.com/@tomatoshi2",
        profile_urls: %w[https://www.youtube.com/@tomatoshi2 https://www.youtube.com/channel/UCMlwuU1RF0YYDnFlmnM_sJA],
        display_name: "Tomatoshi2",
        username: "tomatoshi2",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["cavedweller", "https://www.youtube.com/hashtag/cavedweller"],
          ["thebrokenscript", "https://www.youtube.com/hashtag/thebrokenscript"],
          ["minecraft", "https://www.youtube.com/hashtag/minecraft"],
          ["minecrafthorror", "https://www.youtube.com/hashtag/minecrafthorror"],
          ["minecraftmods", "https://www.youtube.com/hashtag/minecraftmods"],
          ["videoessay", "https://www.youtube.com/hashtag/videoessay"],
        ],
        dtext_artist_commentary_title: "Minecraft Mods Can NEVER Be Scary",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          In this video, I analyze why Minecraft horror mods have the reputation that it does. Mods like Cave Dwellers are not received positively, so I aimed to explain why that is the case. This is a combination of sandbox genre, modding, and the audience that make/play the mods.

          Tags:
          "#cavedweller":[https://www.youtube.com/hashtag/cavedweller] "#thebrokenscript":[https://www.youtube.com/hashtag/thebrokenscript] "#minecraft":[https://www.youtube.com/hashtag/minecraft] "#minecrafthorror":[https://www.youtube.com/hashtag/minecrafthorror] "#minecraftmods":[https://www.youtube.com/hashtag/minecraftmods] "#videoessay":[https://www.youtube.com/hashtag/videoessay]
        EOS
      )
    end

    context "A Youtube video with a Japanese title and description that's auto-translated in other languages" do
      strategy_should_work(
        "https://www.youtube.com/watch?v=MeIhmwXRo30",
        image_urls: [],
        page_url: "https://www.youtube.com/watch?v=MeIhmwXRo30",
        profile_url: "https://www.youtube.com/@Tripl3jp",
        profile_urls: %w[https://www.youtube.com/@Tripl3jp https://www.youtube.com/channel/UClcMHz6g52n0tmZ8QFt8uCA],
        display_name: "とりぷる / Tripl3",
        username: "Tripl3jp",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["ホロライブ", "https://www.youtube.com/hashtag/ホロライブ"],
          ["ホロライブ切り抜き", "https://www.youtube.com/hashtag/ホロライブ切り抜き"],
          ["切り抜き", "https://www.youtube.com/hashtag/切り抜き"],
          ["手描き", "https://www.youtube.com/hashtag/手描き"],
          ["hololive", "https://www.youtube.com/hashtag/hololive"],
          ["hololiveclip", "https://www.youtube.com/hashtag/hololiveclip"],
          ["clip", "https://www.youtube.com/hashtag/clip"],
          ["vtuber", "https://www.youtube.com/hashtag/vtuber"],
          ["animation", "https://www.youtube.com/hashtag/animation"],
        ],
        dtext_artist_commentary_title: "【手描き】感情ジェットコースター兎田ぺこら【ホロライブ切り抜き/兎田ぺこら】",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          👯‍♀️🥕

          ↓You can watch the English-subtitled version here!
          " • Pekora - Damsel or Delinquent?【Hololive An... ":[https://www.youtube.com/watch?v=EpEO2bBtYds]

          ●Source
          【BIOHAZARD Re4】完全初見！はじめてのバイオハザード４やる！ぺこ！【ホロライブ/兎田ぺこら】※未成年視聴注意
          " • #1【BIOHAZARD Re4】完全初見！はじめてのバイオハザード４やる！ぺこ！【... ":[https://www.youtube.com/watch?v=G_C-kFqxJEM&t=8883s]
          #2【BIOHAZARD Re4】完全初見！はじめてのバイオハザード４やる！ぺこ！【ホロライブ/兎田ぺこら】※未成年視聴注意
          " • #2【BIOHAZARD Re4】完全初見！はじめてのバイオハザード４やる！ぺこ！【... ":[https://www.youtube.com/watch?v=EBou0GACkXk&t=2526s]

          ●Hololive / Vtuber
          兎田ぺこら / Usada Pekora
          " / @usadapekora ":[https://www.youtube.com/channel/UC1DCedRgGHBdm81E1llLhOQ]

          ●Used Music
          Monkeys Spinning Monkeys
          " • Monkeys Spinning Monkeys ":[https://www.youtube.com/watch?v=2eZVbrO6Z1M]
          リコーダー初級 (Recorder beginner)
          " • リコーダー初級｜フリーBGM OpenTracks（旧DOVA-SYNDROME） ... ":[https://www.youtube.com/watch?v=DBex2Csd74c]

          ●Used Sounds
          OtoLogic : <https://otologic.jp>

          ■My Account
          X：<https://x.com/toripuru_3>
          JP Account(とりぷる)：" / @tripl3jp ":[https://www.youtube.com/channel/UClcMHz6g52n0tmZ8QFt8uCA]
          EN Account(Tripl3)：" / @tripl3en ":[https://www.youtube.com/channel/UCxDNOCU8jsyXtFWarU9mUVA]

          "#ホロライブ":[https://www.youtube.com/hashtag/ホロライブ] "#ホロライブ切り抜き":[https://www.youtube.com/hashtag/ホロライブ切り抜き] "#切り抜き":[https://www.youtube.com/hashtag/切り抜き] "#手描き":[https://www.youtube.com/hashtag/手描き] "#Hololive":[https://www.youtube.com/hashtag/hololive] "#Hololiveclip":[https://www.youtube.com/hashtag/hololiveclip] "#Clip":[https://www.youtube.com/hashtag/clip] "#Vtuber":[https://www.youtube.com/hashtag/vtuber] "#Animation":[https://www.youtube.com/hashtag/animation]
        EOS
      )
    end
  end
end
