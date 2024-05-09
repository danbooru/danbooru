# frozen_string_literal: true

require "test_helper"

module Sources
  class BloggerTest < ActiveSupport::TestCase
    context "Blogger:" do
      context "A blogger.googleusercontent.com/img/b sample image URL" do
        strategy_should_work(
          "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s320/tali-litho.jpg",
          image_urls: %w[https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/d/tali-litho.jpg],
          media_files: [{ file_size: 87_668 }],
          page_url: nil
        )
      end

      context "A blogger.googleusercontent.com/img/a/ sample image URL" do
        strategy_should_work(
          "https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF",
          image_urls: %w[https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF=d],
          media_files: [{ file_size: 87_668 }],
          page_url: nil
        )
      end

      context "A 1.bp.blogspot.com sample image URL" do
        strategy_should_work(
          "https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s1600/Blog%2BImage%2B3%2B%25281%2529.png",
          image_urls: %w[https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/d/Blog+Image+3+%25281%2529.png],
          media_files: [{ file_size: 170_673 }],
          page_url: nil
        )
      end

      context "A bp0.blogger.com sample image URL" do
        strategy_should_work(
          "http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/s400/Copy+of+milla-jovovich-2.jpg",
          image_urls: %w[https://1.bp.blogspot.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/d/Copy+of+milla-jovovich-2.jpg],
          media_files: [{ file_size: 100_662 }],
          page_url: nil
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
          artist_name: "VincentCCart",
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
          dtext_artist_commentary_desc: <<~EOS.chomp
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
            https://1.bp.blogspot.com/-gFYxDsgG8iA/UgZvCWk10pI/AAAAAAAAAg8/iHVaK5NGg8o/d/01.jpg
            https://1.bp.blogspot.com/-A-fxc8zPwOE/UgZvGnKqQNI/AAAAAAAAAhE/yGExUNMVqoI/d/02.jpg
            https://1.bp.blogspot.com/-SZGjvHeGRp8/UgZvQ2b38ZI/AAAAAAAAAhM/vt19VigNQxY/d/03.jpg
            https://1.bp.blogspot.com/-ad7nJ4yBldk/UgZvr9J2-jI/AAAAAAAAAhs/7ngB3S775bE/d/04.jpg
            https://1.bp.blogspot.com/-FABjITxmfZ8/UgZvqOFi0zI/AAAAAAAAAhc/dzeBfGAk3IE/d/05.jpg
            https://1.bp.blogspot.com/-ENqI2ZjzmeQ/UgZvsHP6H6I/AAAAAAAAAho/oRMVzajcz2c/d/06.jpg
            https://1.bp.blogspot.com/-6ChPE0tvwWA/UgZvuh4ssQI/AAAAAAAAAh0/KdXmt79GhHk/d/07.jpg
            https://1.bp.blogspot.com/-jRB0Xhu8aWY/UgZvuzv0cXI/AAAAAAAAAh8/hK7W_absNSk/d/08.jpg
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
          profile_url: "https://jenolab.blogspot.com",
          profile_urls: %w[https://jenolab.blogspot.com https://www.blogger.com/profile/01791927505974594309],
          artist_name: "Jeno",
          tag_name: "jenolab",
          other_names: ["Jeno", "jenolab"],
          tags: [],
          dtext_artist_commentary_title: "BD",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "Folie" publié dans "Envie 2 Fraises" -Oroproductions-

            "[image]":[https://1.bp.blogspot.com/-gFYxDsgG8iA/UgZvCWk10pI/AAAAAAAAAg8/iHVaK5NGg8o/d/01.jpg]

            "[image]":[https://1.bp.blogspot.com/-A-fxc8zPwOE/UgZvGnKqQNI/AAAAAAAAAhE/yGExUNMVqoI/d/02.jpg]

            "[image]":[https://1.bp.blogspot.com/-SZGjvHeGRp8/UgZvQ2b38ZI/AAAAAAAAAhM/vt19VigNQxY/d/03.jpg]

            "[image]":[https://1.bp.blogspot.com/-ad7nJ4yBldk/UgZvr9J2-jI/AAAAAAAAAhs/7ngB3S775bE/d/04.jpg]

            "[image]":[https://1.bp.blogspot.com/-FABjITxmfZ8/UgZvqOFi0zI/AAAAAAAAAhc/dzeBfGAk3IE/d/05.jpg]

            "[image]":[https://1.bp.blogspot.com/-ENqI2ZjzmeQ/UgZvsHP6H6I/AAAAAAAAAho/oRMVzajcz2c/d/06.jpg]

            "[image]":[https://1.bp.blogspot.com/-6ChPE0tvwWA/UgZvuh4ssQI/AAAAAAAAAh0/KdXmt79GhHk/d/07.jpg]

            "[image]":[https://1.bp.blogspot.com/-jRB0Xhu8aWY/UgZvuzv0cXI/AAAAAAAAAh8/hK7W_absNSk/d/08.jpg]
          EOS
        )
      end

      context "A blog post on a custom domain" do
        strategy_should_work(
          "https://www.micmicidol.club/2024/04/weekly-playboy-20240506-no19-46.html",
          image_urls: %w[
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhkW0FeG5zkbXPNPO6Fw999yH4YTJ8_7d9kULElPpW2ihaoXwVyN5MRmojnWUv9Ig1ovf7TkaWN5JnYvEc6WUq7YqbYywOD29XKBIaDiCxIVPJWWaZDxHfPC0Y_D9lMS2hiWauhQ2-6JXRYTd_RLj4oErtHFh4OPHGgnIXHM6jbzpAoHekVyBVbYbwMmy2-/d/2-001-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjGRsWqvuTqSt6DLZU3tvv61TZTKHcBeLE63t8rCULvXFbye-ZZrvTp_hIbI1ytaSLFS1CI_4Xa-ivqVtsooFG1TIu8nXcYvlT5mCW5RMLxR54G6wdXrnpouCsjjOpkN8TMAalv8OtkgxoRcn81QldYxapDTzK78fFDnUW2EZw0aZYeD-1AX3ZLRjBgsveB/d/2-002-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEi-3DQKi5VlhOt-H0Q21UhF1bAAquFjk_MK3w_Ivb_e-OFH8sFgCsa5t0e6ga4nVRKpUItIm7y2WUjdRadJ1E0IFT79W7A4P1QZNRfC_8-PLibw42iwV_66c_YGi5QA8-q8VDHSGqgy_YES8FW21AksHDZfWL5JScKaz9SX9M120nl-4Jyx8Tc4tCevoPor/d/2-003-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgJYLPFZrLno6V8dhpLztuFmFtP5eYfiQ_1Znc-2q3buCL-_CNFMc379xvrX9nfdAHPMhoKGacndWoU7wHXduMC8ZW3EJ5e9Wlk5LIVZ5MASY8ZZaS11BwA_Jyh5HrCf2aPgTrFqOp1Xjvr0PLg8Q0NJRynVN76Psievuuo4QScO7QsXQ6Dr05WjZiqq436/d/2-004-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjFoWHsNG69HVuMjAgx4I-xacQtxNW2ik0c0LOYQ6QPRrvhBoc5lTFWwFQoyIATkoF4mJWkkB7XQarKT7ph9IpzBY_bNae7AKhzpZ6DnU0FMYKZCUpGeaKPcO88fsBqMC_GGmqvfm_OlMEA5Jyu32x5bSQeDOqRCJPAjzaN7xcxRGgyEbgK8pFJni0WKIE2/d/2-005-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjJRgBfvTgLlHkWLeB0E_MEMMk6cwrTsbvxX2ufmehTJTouSeps6-xW20sAPcb1gaNJwVkSIjxV_4UY-6kW-5Ef69J60Ede2nCys2zO1iIeKQyHaQRGLhGXiYoLHgaUKAv5gWKEnwWkx9lKRO1l1u9-ekmQJbjF7VNiVP_jWiyQgphPcqgviHxu1N44Z_eS/d/2-006-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj3ZzDaTavY7UtDHz5BZbiGNzCBmc6-TV163xFw-TeWo0VzxTbIo39VCFLrKKwZRSU975f_gtEAW4qAIg950z9zj9yZSf0KVhha_FhuBD6gG7R9QIT3hLTjcB0R5IhhWWTSzt9JoqemJw29RE73Ngvdgs5PXLJ77qhaPjB1AtuhkwT_agYsfYJDzftuIlyu/d/2-007-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhJejVPsHzKPXU1Xjr8w33K3W7yIvDOmafQY8Y5WqqpHmyY4QdHDOPN6FH34Ub7lOVx2tL25BXAgSfi6fEKEIKEzsTnI7eLkiIHwTA1u_PgO7UR_aWaL7os3gwD8BgcAnCAS8HZQAxUb010WPYjaynSiOcDUy16rBvBs-FN4Q_8yu1QXiVdEtQ2N1OpxQI1/d/2-008-micmicidol.jpg
            https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEiXW1A2VLq4XC21P6UCArcJxoWoD9F-EQ_uyWJhLKxFJ6fcYc3is-Utz7mLKQF2uway5_CAg9zNrRJAc-4XZOl3IROuPXNFAlpyD6vVguVnIduCCKNvc95yDJB3aT7BXRHbW94iio9SN8TovTGnKNWGOBQhxLjAA1FeiobP5ca35rZnPYqJ0gm5ZQ6xOe49/d/2-b01-micmicidol.jpg
          ],
          media_files: [
            { file_size: 585_511 },
            { file_size: 655_733 },
            { file_size: 1_215_986 },
            { file_size: 1_539_545 },
            { file_size: 1_041_313 },
            { file_size: 1_004_377 },
            { file_size: 987_982 },
            { file_size: 1_279_556 },
            { file_size: 68_596 },
          ],
          page_url: "https://www.micmicidol.club/2024/04/weekly-playboy-20240506-no19-46.html",
          profile_url: "https://www.micmicidol.club",
          profile_urls: %w[https://www.micmicidol.club https://www.blogger.com/profile/02481205275454122028],
          artist_name: "MIC MIC IDOL",
          tag_name: nil,
          other_names: ["MIC MIC IDOL"],
          tags: [
            ["- Japan Magazine", "https://www.micmicidol.club/search/label/- Japan Magazine"],
            ["Weekly Playboy", "https://www.micmicidol.club/search/label/Weekly Playboy"],
            ["丹生明里", "https://www.micmicidol.club/search/label/丹生明里"],
            ["日向坂46", "https://www.micmicidol.club/search/label/日向坂46"],
          ],
          dtext_artist_commentary_title: "Weekly Playboy 2024.05.06 No.19 丹生明里（日向坂46）『海へ行く日』",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A blog post with image URLs in the `img[data-src]` attribute" do
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
          artist_name: "Jamiu Akinyemi",
          tag_name: nil,
          other_names: ["Jamiu Akinyemi"],
          tags: [
            ["Gaming", "https://www.kefblog.com.ng/search/label/Gaming"],
          ],
          dtext_artist_commentary_title: "GTA 5: Download and Install GTA V Apk and OBB (Highly Compressed)"
        )
      end

      context "A deleted or nonexistent blog post" do
        strategy_should_work(
          "http://benbotport.blogspot.com/2099/06/post.html",
          image_urls: [],
          page_url: "https://benbotport.blogspot.com/2099/06/post.html",
          profile_url: "https://benbotport.blogspot.com",
          profile_urls: %w[https://benbotport.blogspot.com],
          artist_name: nil,
          tag_name: "benbotport",
          other_names: ["benbotport"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A deleted or nonexistent blog" do
        strategy_should_work(
          "https://qoigjqweroig.blogspot.com/2099/01/post.html",
          image_urls: [],
          page_url: "https://qoigjqweroig.blogspot.com/2099/01/post.html",
          profile_url: "https://qoigjqweroig.blogspot.com",
          profile_urls: %w[https://qoigjqweroig.blogspot.com],
          artist_name: nil,
          tag_name: "qoigjqweroig",
          other_names: ["qoigjqweroig"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s1600/tali-litho.jpg"))
        assert(Source::URL.image_url?("https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s0/"))
        assert(Source::URL.image_url?("https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/"))
        assert(Source::URL.image_url?("https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF"))
        assert(Source::URL.image_url?("https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF=s0"))
        assert(Source::URL.image_url?("https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s1600/Blog%2BImage%2B3%2B%25281%2529.png"))
        assert(Source::URL.image_url?("https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s0/"))
        assert(Source::URL.image_url?("https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/"))
        assert(Source::URL.image_url?("http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/s400/Copy+of+milla-jovovich-2.jpg"))
        assert(Source::URL.image_url?("http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/d/"))
        assert(Source::URL.image_url?("http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0"))

        assert(Source::URL.page_url?("http://benbotport.blogspot.com/2011/06/mass-effect-2.html"))
        assert(Source::URL.page_url?("http://vincentmcart.blogspot.com.es/2016/05/poison-sting.html?zx=141d0a1a4c3e3ba"))

        assert(Source::URL.profile_url?("https://www.blogger.com/profile/05678559930985966952"))
        assert(Source::URL.profile_url?("http://benbotport.blogspot.com"))
        assert(Source::URL.profile_url?("http://vincentmcart.blogspot.com.es"))
      end
    end
  end
end
