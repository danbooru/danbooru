require "test_helper"

module Source::Tests::Extractor
  class BloggerExtractorTest < ActiveSupport::ExtractorTestCase
    context "A blogger.googleusercontent.com/img/b sample image URL" do
      strategy_should_work(
        "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s320/tali-litho.jpg",
        image_urls: %w[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/d/tali-litho.jpg],
        media_files: [{ file_size: 87_668 }],
        page_url: nil,
      )
    end

    context "A blogger.googleusercontent.com/img/a/ sample image URL" do
      strategy_should_work(
        "https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF",
        image_urls: %w[https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF=d],
        media_files: [{ file_size: 87_668 }],
        page_url: nil,
      )
    end

    context "A 1.bp.blogspot.com sample image URL" do
      strategy_should_work(
        "https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s1600/Blog%2BImage%2B3%2B%25281%2529.png",
        image_urls: %w[https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/d/Blog+Image+3+%25281%2529.png],
        media_files: [{ file_size: 170_673 }],
        page_url: nil,
      )
    end

    context "A bp0.blogger.com sample image URL" do
      strategy_should_work(
        "http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/s400/Copy+of+milla-jovovich-2.jpg",
        image_urls: %w[https://1.bp.blogspot.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/d/Copy+of+milla-jovovich-2.jpg],
        media_files: [{ file_size: 100_662 }],
        page_url: nil,
      )
    end

    context "A blog post from a blogspot.com.es domain" do
      strategy_should_work(
        "http://vincentmcart.blogspot.com.es/2016/05/poison-sting.html?zx=141d0a1a4c3e3ba",
        image_urls: %w[
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDbTydS5rX1TZaozvjl6veU8DMIgZPqzPbE13ccagELyBYtbtVv1AiItiJuj1YQMTq5O0sQPlWXTfprEG-2ZFc8F2d8LNuOnMlzYp_-aRPkPe1AJf78G9okl5yddt_dhqF273_0H1ir5o/d/Captura+de+pantalla+2015-12-09+a+las+15.55.30.png
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi6Lo3R7LVlKy_qOD3fDh4r0s_UcdzdEOXyngHjsEOHy3BbVmqSu3OaxGlcAWdPF-MxHCLIuoukUaIqGG_5LN481yaDSXDL1uGk-oBvDjPlQKSbSHyC3c-EjXK-TYBOs9tqDu_uimB6dtg/d/Captura+de+pantalla+2015-12-09+a+las+15.55.33.png
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjvOfg8KMkYBkErlB72rdHxX3McnJ2tPKBMavsJ61BWQFsLoCA5CeNye_5kDFurxbv3XFXfhJzFQXRKTClVpmTTUrxv367KGcU_-BvGkCbyUgk3Df0YkPPWeMOZxQBoXDncPQ6RT3mOV34/d/Captura+de+pantalla+2016-05-18+a+la%2528s%2529+19.17.46.png
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjQ-Gwp0IzLV_KBaDpWatMl86E4aYw2hEs4YU6VTtUuIrAVRF4v7LzrndmPj5gyE3_UpzjdJ_MDHB7VzeJxuNtUW1izrnFzQGgAJUJpbEdEZXjJb_08FAewk1VNM1WOT_mfSyiv9OQJhAI/d/poison_roxy_01_vincentCC.png
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEguhlpLjjMFOEuBzpKEsVXjGmcAlmNti9QMgViHBc9E-ZK1AKSBH7agAE-3IxCjf4xCdFriqvOSSnP5CMAfoNkkKbN5lUuGYoolLcYyUM4mhbuD7vSLotbDfr5-MRlhpaC3kxlbq4121oM/d/poison_roxy_02_vincentCC.png
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjb0xs0SXA4cmBHoJbzhdkht2-v3TelU2C7YaoO5x8B8IT-s-Dm9ea-GmDMOzURWZWa_6ZUeMdC3VfPGhhpbeLAM-owhx4ObxnotZmT6CcaBRmxrIA8N97Gbyv8msKNFwLqFoxPcQc6Rl4/d/poison_roxy_03_vincentCC.png
        ],
        media_files: [
          { file_size: 589_231 },
          { file_size: 607_455 },
          { file_size: 430_999 },
          { file_size: 2_478_311 },
          { file_size: 2_481_686 },
          { file_size: 2_605_749 },
        ],
        page_url: "https://vincentmcart.blogspot.com/2016/05/poison-sting.html",
        profile_url: "https://vincentmcart.blogspot.com",
        profile_urls: %w[https://vincentmcart.blogspot.com https://www.blogger.com/profile/07491071744928618117],
        display_name: "VincentCCart",
        username: "vincentmcart",
        tag_name: "vincentmcart",
        other_names: ["VincentCCart", "vincentmcart"],
        tags: [
          ["badass", "https://vincentmcart.blogspot.com/search/label/badass"],
          ["Big Breasts", "https://vincentmcart.blogspot.com/search/label/Big Breasts"],
          ["bigtits", "https://vincentmcart.blogspot.com/search/label/bigtits"],
          ["cum", "https://vincentmcart.blogspot.com/search/label/cum"],
          ["cumshot", "https://vincentmcart.blogspot.com/search/label/cumshot"],
          ["Final Fight", "https://vincentmcart.blogspot.com/search/label/Final Fight"],
          ["futa", "https://vincentmcart.blogspot.com/search/label/futa"],
          ["heels", "https://vincentmcart.blogspot.com/search/label/heels"],
          ["hentai art", "https://vincentmcart.blogspot.com/search/label/hentai art"],
          ["pegging", "https://vincentmcart.blogspot.com/search/label/pegging"],
          ["pink hair.", "https://vincentmcart.blogspot.com/search/label/pink hair."],
          ["Poison", "https://vincentmcart.blogspot.com/search/label/Poison"],
          ["porn", "https://vincentmcart.blogspot.com/search/label/porn"],
          ["Roxy", "https://vincentmcart.blogspot.com/search/label/Roxy"],
          ["shemale", "https://vincentmcart.blogspot.com/search/label/shemale"],
          ["vincentcc", "https://vincentmcart.blogspot.com/search/label/vincentcc"],
          ["vincentccart", "https://vincentmcart.blogspot.com/search/label/vincentccart"],
        ],
        dtext_artist_commentary_title: "Poison sting",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          What a commission! It has been hard, I have to admit that this scene has a pose between the most difficult ones I've ever worked. It couldn't be another way. My first scene with Poison. And Roxy! A truly challenge, but you know what they say: a smooth sea never made a skilled sailor.

          The commissioner had an important specification for this scene, it had to be up against the glass window at the front of the subway.

          After reading this idea, my imagination started to run fast: these two rough and energetic girls with their physiques of gymnast; long supple legs and an extremely slender waist, with toned muscles, having the kind of sex that's too passionate to get undressed... I saw Roxy's mouth, wide open moaning with ecstasy while she cums wildly, I saw in my mind the exact glance in Poison's eyes. And suddenly I noticed. Wet underwear.

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjDbTydS5rX1TZaozvjl6veU8DMIgZPqzPbE13ccagELyBYtbtVv1AiItiJuj1YQMTq5O0sQPlWXTfprEG-2ZFc8F2d8LNuOnMlzYp_-aRPkPe1AJf78G9okl5yddt_dhqF273_0H1ir5o/d/Captura+de+pantalla+2015-12-09+a+las+15.55.30.png]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi6Lo3R7LVlKy_qOD3fDh4r0s_UcdzdEOXyngHjsEOHy3BbVmqSu3OaxGlcAWdPF-MxHCLIuoukUaIqGG_5LN481yaDSXDL1uGk-oBvDjPlQKSbSHyC3c-EjXK-TYBOs9tqDu_uimB6dtg/d/Captura+de+pantalla+2015-12-09+a+las+15.55.33.png]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjvOfg8KMkYBkErlB72rdHxX3McnJ2tPKBMavsJ61BWQFsLoCA5CeNye_5kDFurxbv3XFXfhJzFQXRKTClVpmTTUrxv367KGcU_-BvGkCbyUgk3Df0YkPPWeMOZxQBoXDncPQ6RT3mOV34/d/Captura+de+pantalla+2016-05-18+a+la%2528s%2529+19.17.46.png]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjQ-Gwp0IzLV_KBaDpWatMl86E4aYw2hEs4YU6VTtUuIrAVRF4v7LzrndmPj5gyE3_UpzjdJ_MDHB7VzeJxuNtUW1izrnFzQGgAJUJpbEdEZXjJb_08FAewk1VNM1WOT_mfSyiv9OQJhAI/d/poison_roxy_01_vincentCC.png]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEguhlpLjjMFOEuBzpKEsVXjGmcAlmNti9QMgViHBc9E-ZK1AKSBH7agAE-3IxCjf4xCdFriqvOSSnP5CMAfoNkkKbN5lUuGYoolLcYyUM4mhbuD7vSLotbDfr5-MRlhpaC3kxlbq4121oM/d/poison_roxy_02_vincentCC.png]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjb0xs0SXA4cmBHoJbzhdkht2-v3TelU2C7YaoO5x8B8IT-s-Dm9ea-GmDMOzURWZWa_6ZUeMdC3VfPGhhpbeLAM-owhx4ObxnotZmT6CcaBRmxrIA8N97Gbyv8msKNFwLqFoxPcQc6Rl4/d/poison_roxy_03_vincentCC.png]
        EOS
      )
    end

    context "A blog page URL" do
      strategy_should_work(
        "http://jenolab.blogspot.com/p/bd.html",
        image_urls: %w[
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgKOx3SfHzVaaj8G19RfDnm-6NKRjHj197jucylgMJsH9OyGGcdqK0yWRTHeDygGeQGT-aDkr9szOFlQHoCo2F8HcLmbk5qeL4NC_Atl8NV603CdALUfVj0yO62GJCzscEgWdSiA0lNaLiF/d/01.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhUFuuGoCNva89j420q0QigLKNhXKZ8fQtPmONGXQ-7uoeX4Nd6DQ5CSe5zQ2dbmBODUbZdGSi4JCpDC7exb8xZY4yLS5dLTQwWL3AnK3uEMnQam0U07l0NtacGbX5mp09d7Hm49kn2BVwb/d/02.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiNVG52GdvN2_Lv2b0e2majD694aOsD8qcRc2wrhEnQEGK-5lX0nSU64Eub9chSWnSp8yrhK-x8x6EeQniVDsrbytfzPpg17PXroUUaaqF_37HWYqAlE3od3cSrkF9-fFPQC_kDqvysgAE-/d/03.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgv_tjOnu7onl5WqclEz64hO6Q85Xdo6nQpqlZ4q7ykNTnkwmtWlQIb0M0RgYFA1jNcZGFDseHzjOZ0Mf0xH6XptpTS78nP9c3IW6GVl9CQhYkg9q2P0VA01eyPYYTiXMmjRaM4YmR5YFQx/d/04.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhSwZvVlnTaG3zvqa4jb7wYzwv_j7N7WZ99jn6KR5fNxzwZFt9wXdKnmMb7BiM5_sR2peGr8_X9MyHBS4rUmy9KpDVifwl9ldw0AtWP6NpxFRrndGVSRL-DjpAKUhitts8JhClNSVzMhQGi/d/05.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgJ9gqIywKnhJa6JDUC2hAuaYj4xybCAOEbW8BOlABdRC8TXXn6rQhj_MJGeq4ob30WuI-N66R7-FvuoMC7KwclWKhToD45KAp_Uws_PcL9RX7-s-FP_bdBwqvuS5CFu5ZvS-oYoLalmLuH/d/06.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiJJ-VM-_HH4JvU5BvFVufgUCrsIkVIwowMgCghVEeVmdRoNqwg07rzVlgbFjBaoZM6hoN3H0AM6CXWdhfbHhDdvwLaGjxFayZBwrVmhuwwUTnVaEYWHXwaOi_GD-Bl0qVLmtDWZ8Z0xUMx/d/07.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgJed6c__jHMNY4OcHi0_LzPF3jQ8KlYMPa-msoZ4CaWuMEp94WwLIjt1HbnjoUXFVULH58hVRhrwRd1kyIPD97Jp2Zq6_oree3lRy3DMfOdR1bXv8Uv1hPGwQd5pKHVGaquzL6l5cnBZE4/d/08.jpg
        ],
        media_files: [
          { file_size: 621_610 },
          { file_size: 607_408 },
          { file_size: 612_806 },
          { file_size: 664_385 },
          { file_size: 477_528 },
          { file_size: 546_559 },
          { file_size: 586_982 },
          { file_size: 469_124 },
        ],
        page_url: "https://jenolab.blogspot.com/p/bd.html",
        profile_urls: %w[https://jenolab.blogspot.com https://www.blogger.com/profile/01791927505974594309],
        display_name: "Jeno",
        username: "jenolab",
        tags: [],
        dtext_artist_commentary_title: "BD",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "Folie" publié dans "Envie 2 Fraises" -Oroproductions-

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgKOx3SfHzVaaj8G19RfDnm-6NKRjHj197jucylgMJsH9OyGGcdqK0yWRTHeDygGeQGT-aDkr9szOFlQHoCo2F8HcLmbk5qeL4NC_Atl8NV603CdALUfVj0yO62GJCzscEgWdSiA0lNaLiF/d/01.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhUFuuGoCNva89j420q0QigLKNhXKZ8fQtPmONGXQ-7uoeX4Nd6DQ5CSe5zQ2dbmBODUbZdGSi4JCpDC7exb8xZY4yLS5dLTQwWL3AnK3uEMnQam0U07l0NtacGbX5mp09d7Hm49kn2BVwb/d/02.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiNVG52GdvN2_Lv2b0e2majD694aOsD8qcRc2wrhEnQEGK-5lX0nSU64Eub9chSWnSp8yrhK-x8x6EeQniVDsrbytfzPpg17PXroUUaaqF_37HWYqAlE3od3cSrkF9-fFPQC_kDqvysgAE-/d/03.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgv_tjOnu7onl5WqclEz64hO6Q85Xdo6nQpqlZ4q7ykNTnkwmtWlQIb0M0RgYFA1jNcZGFDseHzjOZ0Mf0xH6XptpTS78nP9c3IW6GVl9CQhYkg9q2P0VA01eyPYYTiXMmjRaM4YmR5YFQx/d/04.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhSwZvVlnTaG3zvqa4jb7wYzwv_j7N7WZ99jn6KR5fNxzwZFt9wXdKnmMb7BiM5_sR2peGr8_X9MyHBS4rUmy9KpDVifwl9ldw0AtWP6NpxFRrndGVSRL-DjpAKUhitts8JhClNSVzMhQGi/d/05.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgJ9gqIywKnhJa6JDUC2hAuaYj4xybCAOEbW8BOlABdRC8TXXn6rQhj_MJGeq4ob30WuI-N66R7-FvuoMC7KwclWKhToD45KAp_Uws_PcL9RX7-s-FP_bdBwqvuS5CFu5ZvS-oYoLalmLuH/d/06.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiJJ-VM-_HH4JvU5BvFVufgUCrsIkVIwowMgCghVEeVmdRoNqwg07rzVlgbFjBaoZM6hoN3H0AM6CXWdhfbHhDdvwLaGjxFayZBwrVmhuwwUTnVaEYWHXwaOi_GD-Bl0qVLmtDWZ8Z0xUMx/d/07.jpg]

          "[image]":[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgJed6c__jHMNY4OcHi0_LzPF3jQ8KlYMPa-msoZ4CaWuMEp94WwLIjt1HbnjoUXFVULH58hVRhrwRd1kyIPD97Jp2Zq6_oree3lRy3DMfOdR1bXv8Uv1hPGwQd5pKHVGaquzL6l5cnBZE4/d/08.jpg]
        EOS
      )
    end

    context "A blog post on a custom domain" do
      strategy_should_work(
        "https://blogger.googleblog.com/2020/05/a-better-blogger-experience-on-web.html",
        image_urls: %w[
          https://lh5.googleusercontent.com/kWHfhyDmS0K6WMbTlfDV8Hq9RKq7Cs2sbPVl0otK3zDV5jNDO0SxM5-Ot89Wo3E11QvmNMI7VYMimqP-Vg9li-cz0cimWiGpJM65-uOSCmAvSN5n7M-lGcNWNW2u0cAfA54ZsGhZ=d
          https://lh4.googleusercontent.com/B-Tx1tl3m3_sH_4HiCg0XxhlTka0IV82jwT2LT4T9kzbXF15nMxjwNGe3NUAz-F42irNGdDINUiw4DM---nX_87Bb0X3OL_s5L19Rlyfhtm6oyEMNR1R4473TzkgsuxWQ3HXOIOV=d
        ],
        media_files: [
          { file_size: 228_413 },
          { file_size: 233_651 },
        ],
        page_url: "https://blogger.googleblog.com/2020/05/a-better-blogger-experience-on-web.html",
        profile_urls: %w[https://blogger.googleblog.com https://www.blogger.com/profile/04878303798219763289],
        display_name: "A Googler",
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "A better Blogger experience on the web",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Since 1999, millions of people have expressed themselves on Blogger. From detailed posts about almost every "apple variety":[https://adamapples.blogspot.com/] you could ever imagine to a blog dedicated to "the art of blogging":[https://howtoblog.krishnainfotron.com/] itself, the ability to easily share, publish and express oneself on the web is at the core of Blogger’s mission. As the web constantly evolves, we want to ensure anyone using Blogger has an easy and intuitive experience publishing their content to the web.

          That’s why we’ve been slowly introducing an improved web experience for Blogger. Give the fresh interface a spin by clicking “Try the New Blogger” in the left-hand navigation pane.

          Click the “Try the New Blogger” button to see Blogger’s refreshed look and feel.

          In addition to a fresh feel, Blogger is now responsive on the web, making it easier to use on mobile devices. By investing in an improved web platform, it allows the potential for new features in the future.

          Blogger’s new responsive design makes it easy to manage your blog on-the-go.

          Learn more about the page-specific updates we’ve released to make your Blogger experience even better:

          Stats

          The redesigned Stats page helps you focus on the most important data from your blog by highlighting your most recent post.

          Comments

          A fresh Comments page helps you connect with readers more easily by surfacing areas that need your attention, like comment moderation.

          Posts

          We’ve improved support for "Search Operators":[https://support.google.com/blogger/answer/9675453?hl=en] on the Posts page to help you filter your Blogger posts and page search results more easily.

          Editor

          The newly enhanced Editor page introduces table support, enables better transliteration, and includes an improved image/video upload experience.

          Reading List

          Even if you don’t create from your phone, it’s now easier than ever to read blogs from other creators while you’re on the go.

          Settings

          We’ve streamlined the Settings page to help you manage all your controls from one place.

          We’ll be moving everyone to the new interface over the coming months. Starting in late June, many Blogger creators will see the new interface become their default, though they can revert to the old interface by clicking “Revert to legacy Blogger” in the left-hand navigation. By late July, creators will no longer be able to revert to the legacy Blogger interface.

          We recommend getting ahead of the transition by opting into the experience today. Be sure to let us know what you think about the new design by tapping the Help icon in the top navigation bar. We can’t wait to see how Blogger creators use the latest updates to share their voice with the world.

          [i]Posted by Fontaine on behalf of the Blogger team[/i]
        EOS
      )
    end

    context "A blog post with image URLs in the `img[data-src]` attribute" do
      setup do
        skip "Dead site"
      end

      strategy_should_work(
        "https://www.kefblog.com.ng/2022/05/gta-v-5-download-install-apk-obb.html",
        image_urls: %w[
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjEoc9E_8q5tt_xb5c0-G_47Q9iYXhc_ETNan8dvDhZUYJQpDN0taHHoVdQbyHZGBJ_Ub68JKXTuv04EMtVoqlwPyAAx3z-BeiQ98r3VUexkIpr7UHL_KeYp8MmYpuy4R6wxrYOpVIX_tfPG8EgZl6wQB7euXACech960rTc0zXTBaLA_spkw2KjNULeg/d/IMG_20220505_134738.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhgSj0QD1j8-0joTiN8InX2frSGiJX-05N-KX8VQFrmXNuK52hv_3tGlcCP7TAkYG0GIe7_w1uetaUnx-PoxMXwnO5aWuNyw1sBJfSFnns3WAYtxc1OMNDQHcFPZZLBTpvR-v2GM5XvOzsKfRu-Lb_V88usBMuT31Sr5aBn99O1vwEe4bslN1eJEj-0OQ/d/IMG_20220505_134858.jpg
          https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEicqY51pXEEmsGjpm1afdoAfU9OniOfB635TStppBPxfIoFU1cIRaT25KM8ZPv1uaP78JP_sCvqvHFe7E2puALXpSx-xV5gqO7J-1tkKybxYFoB81iXM7B1gSUa8T5vI0dW6Uu0e2qo5GNxzKvc_Rf6YlZl6CIYFz7SPA6CVBocV3ICKl74mbQ9ntlGwA/d/z-cpu_for_64bits.jpg
        ],
        media_files: [
          { file_size: 230_196 },
          { file_size: 50_360 },
          { file_size: 66_383 },
        ],
        page_url: "https://www.kefblog.com.ng/2022/05/gta-v-5-download-install-apk-obb.html",
        profile_url: "https://www.kefblog.com.ng",
        profile_urls: %w[https://www.kefblog.com.ng https://www.blogger.com/profile/18336503116577447466],
        display_name: "Jamiu Akinyemi",
        username: nil,
        tag_name: "jamiu_akinyemi",
        other_names: ["Jamiu Akinyemi"],
        tags: [
          ["Gaming", "https://www.kefblog.com.ng/search/label/Gaming"],
        ],
        dtext_artist_commentary_title: "GTA 5: Download and Install GTA V Apk and OBB (Highly Compressed)",
      )
    end

    context "A deleted or nonexistent blog post" do
      strategy_should_work(
        "http://benbotport.blogspot.com/2099/06/post.html",
        image_urls: [],
        page_url: "https://benbotport.blogspot.com/2099/06/post.html",
        profile_url: "https://benbotport.blogspot.com",
        profile_urls: %w[https://benbotport.blogspot.com],
        display_name: nil,
        username: "benbotport",
        tag_name: "benbotport",
        other_names: ["benbotport"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted or nonexistent blog" do
      strategy_should_work(
        "https://qoigjqweroig.blogspot.com/2099/01/post.html",
        image_urls: [],
        page_url: "https://qoigjqweroig.blogspot.com/2099/01/post.html",
        profile_url: "https://qoigjqweroig.blogspot.com",
        profile_urls: %w[https://qoigjqweroig.blogspot.com],
        display_name: nil,
        username: "qoigjqweroig",
        tag_name: "qoigjqweroig",
        other_names: ["qoigjqweroig"],
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
