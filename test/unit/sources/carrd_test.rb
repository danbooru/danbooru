# frozen_string_literal: true

require "test_helper"

module Sources
  class CarrdTest < ActiveSupport::TestCase
    context "Carrd:" do
      context "An image URL that doesn't have an _original version" do
        strategy_should_work(
          "https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5",
          image_urls: %w[https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg],
          media_files: [{ file_size: 75_371 }],
          page_url: nil,
          profile_urls: %w[https://rosymiz.carrd.co]
        )
      end

      context "A sample image URL that has an _original version" do
        strategy_should_work(
          "https://caminukai-art.carrd.co/assets/images/gallery21/a86d9fc4.jpg?v=3850522b",
          image_urls: %w[https://caminukai-art.carrd.co/assets/images/gallery21/a86d9fc4_original.jpg],
          media_files: [{ file_size: 223_270 }],
          page_url: nil,
          profile_urls: %w[https://caminukai-art.carrd.co]
        )
      end

      context "An _original full image URL" do
        strategy_should_work(
          "https://caminukai-art.carrd.co/assets/images/gallery13/ddc31be4_original.jpg?v=3850522b",
          image_urls: %w[https://caminukai-art.carrd.co/assets/images/gallery13/ddc31be4_original.jpg],
          media_files: [{ file_size: 193_864 }],
          page_url: nil,
          profile_urls: %w[https://caminukai-art.carrd.co]
        )
      end

      context "A video cover image" do
        strategy_should_work(
          "https://rosymiz.carrd.co/assets/videos/video02.mp4.jpg?v=c6f079b5",
          image_urls: %w[https://rosymiz.carrd.co/assets/videos/video02.mp4.jpg],
          media_files: [{ file_size: 454_589 }],
          page_url: nil,
          profile_urls: %w[https://rosymiz.carrd.co]
        )
      end

      context "A page with a single image" do
        strategy_should_work(
          "https://caminukai-art.carrd.co/#fanart-shadowheartguidance",
          image_urls: %w[https://caminukai-art.carrd.co/assets/images/gallery21/a86d9fc4_original.jpg],
          media_files: [{ file_size: 223_270 }],
          page_url: "https://caminukai-art.carrd.co/#fanart-shadowheartguidance",
          profile_url: "https://caminukai-art.carrd.co",
          profile_urls: %w[https://caminukai-art.carrd.co],
          username: "caminukai-art",
          other_names: ["caminukai-art"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            * "[image]":[https://caminukai-art.carrd.co/assets/images/gallery21/a86d9fc4_original.jpg]
            Shadowheart guidance - Baldur's Gate 3

            Illustration of Shadowheart casting guidance, a character from the game Baldur's Gate 3.
          EOS
        )
      end

      context "A page with multiple images that don't have separate pages" do
        strategy_should_work(
          "https://lytell.carrd.co/#portfolio",
          image_urls: %w[
            https://lytell.carrd.co/assets/images/gallery04/bca0b2f2_original.jpg
            https://lytell.carrd.co/assets/images/gallery04/47493cd2_original.jpg
            https://lytell.carrd.co/assets/images/gallery04/3ac05b2e_original.jpg
            https://lytell.carrd.co/assets/images/gallery05/0b8d3183_original.jpg
            https://lytell.carrd.co/assets/images/gallery05/a9a31be0_original.jpg
            https://lytell.carrd.co/assets/images/gallery05/75d61bc7_original.jpg
          ],
          media_files: [
            { file_size: 223_413 },
            { file_size: 213_399 },
            { file_size: 104_650 },
            { file_size: 194_895 },
            { file_size: 271_921 },
            { file_size: 59_213 },
          ],
          page_url: "https://lytell.carrd.co/#portfolio",
          profile_url: "https://lytell.carrd.co",
          profile_urls: %w[https://lytell.carrd.co],
          username: "lytell",
          other_names: ["lytell"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            h1. portfolio

            illustrations - chibis - sketches
            [i]for designs, 2d animation, motion graphic animation please refer to my commission pages for those respective categories for samples[/i]

            * "[image]":[https://lytell.carrd.co/assets/images/gallery04/bca0b2f2_original.jpg]
            * "[image]":[https://lytell.carrd.co/assets/images/gallery04/47493cd2_original.jpg]
            * "[image]":[https://lytell.carrd.co/assets/images/gallery04/3ac05b2e_original.jpg]

            * "[image]":[https://lytell.carrd.co/assets/images/gallery05/0b8d3183_original.jpg]
            * "[image]":[https://lytell.carrd.co/assets/images/gallery05/a9a31be0_original.jpg]
            * "[image]":[https://lytell.carrd.co/assets/images/gallery05/75d61bc7_original.jpg]

            click for full playlist!
          EOS
        )
      end

      context "A page with multiple images that don't have _original versions" do
        strategy_should_work(
          "https://badkrol.carrd.co/#commission",
          image_urls: %w[
            https://badkrol.carrd.co/assets/images/gallery01/42c1e32a.jpg
            https://badkrol.carrd.co/assets/images/gallery01/08d85bf2.jpg
            https://badkrol.carrd.co/assets/images/gallery01/fc3f91db.jpg
            https://badkrol.carrd.co/assets/images/gallery01/548929a2.jpg
            https://badkrol.carrd.co/assets/images/gallery01/9be3f1d6.jpg
            https://badkrol.carrd.co/assets/images/gallery01/1b735c39.jpg
            https://badkrol.carrd.co/assets/images/gallery01/7aa51f1c.jpg
            https://badkrol.carrd.co/assets/images/gallery01/f375193f.jpg
            https://badkrol.carrd.co/assets/images/gallery02/2973b8cd.jpg
            https://badkrol.carrd.co/assets/images/gallery02/5738474b.jpg
            https://badkrol.carrd.co/assets/images/gallery02/3ac7eb98.jpg
            https://badkrol.carrd.co/assets/images/gallery02/a22539e3.jpg
            https://badkrol.carrd.co/assets/images/gallery02/0db4767e.jpg
            https://badkrol.carrd.co/assets/images/gallery02/8b01a93d.jpg
            https://badkrol.carrd.co/assets/images/gallery02/95c2ed27.jpg
            https://badkrol.carrd.co/assets/images/gallery02/4451caa0.jpg
            https://badkrol.carrd.co/assets/images/gallery02/0214174e.jpg
          ],
          media_files: [
            { file_size: 9_104 },
            { file_size: 10_874 },
            { file_size: 5_546 },
            { file_size: 9_944 },
            { file_size: 8_669 },
            { file_size: 21_915 },
            { file_size: 6_460 },
            { file_size: 7_012 },
            { file_size: 8_388 },
            { file_size: 19_498 },
            { file_size: 8_746 },
            { file_size: 5_604 },
            { file_size: 11_945 },
            { file_size: 22_405 },
            { file_size: 14_529 },
            { file_size: 7_488 },
            { file_size: 17_550 },
          ],
          page_url: "https://badkrol.carrd.co/#commission",
          profile_urls: %w[https://badkrol.carrd.co],
          display_name: nil,
          username: "badkrol",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            h1. Commission

            Commissions are currently [b]open[/b]
            Please read T.O.S and Contact

            [hr]

            Anime Style ( *some examples have incomplete rendering)

            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/42c1e32a.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/08d85bf2.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/fc3f91db.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/548929a2.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/9be3f1d6.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/1b735c39.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/7aa51f1c.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery01/f375193f.jpg]

            Illustration

            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/2973b8cd.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/5738474b.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/3ac7eb98.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/a22539e3.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/0db4767e.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/8b01a93d.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/95c2ed27.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/4451caa0.jpg]
            * "[image]":[https://badkrol.carrd.co/assets/images/gallery02/0214174e.jpg]

            Backgrounds

            Note: Simple backgrounds (such as plain colours and basic patterns) are free.
          EOS
        )
      end

      context "A page with images and videos" do
        strategy_should_work(
          "https://rosymiz.carrd.co/#home",
          image_urls: %w[
            https://rosymiz.carrd.co/assets/images/image01.jpg
            https://rosymiz.carrd.co/assets/images/gallery01/1a46013e.jpg
            https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg
            https://rosymiz.carrd.co/assets/images/gallery01/f335f692.jpg
            https://rosymiz.carrd.co/assets/videos/video02.mp4
            https://rosymiz.carrd.co/assets/videos/video03.mp4
          ],
          media_files: [
            { file_size: 18_960 },
            { file_size: 149_988 },
            { file_size: 75_371 },
            { file_size: 54_056 },
            { file_size: 28_206_225 },
            { file_size: 6_043_606 },
          ],
          page_url: "https://rosymiz.carrd.co/#home",
          profile_url: "https://rosymiz.carrd.co",
          profile_urls: %w[https://rosymiz.carrd.co],
          username: "rosymiz",
          other_names: ["rosymiz"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://rosymiz.carrd.co/assets/images/image01.jpg]

            h1. [b]Alice Choi[/b]

            h3. [b]3D Character Art & Animation  -  Motion Designer  [/b]

            [hr]

            h3. Hello! I am a 3D Character Artist, who specializes in 3D modeling and animation for stylized games! I also freelance in motion design, specifically animated illustrations!

            [hr]

            h3. 3D Animation Demo Reel

            h3. 3D Character Art

            * "[image]":[https://rosymiz.carrd.co/assets/images/gallery01/1a46013e.jpg]
            * "[image]":[https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg]
            * "[image]":[https://rosymiz.carrd.co/assets/images/gallery01/f335f692.jpg]

            h3. Motion Design

            "[video]":[https://rosymiz.carrd.co/assets/videos/video02.mp4]

            @GenshinTarot
            Artist: @ddengart

            "[video]":[https://rosymiz.carrd.co/assets/videos/video03.mp4]

            @GenshinTarot
            Artist: @sorryoutofrice
          EOS
        )
      end

      context "A page with data:image/* URLs in the img[data-src] attributes" do
        strategy_should_work(
          "https://silvivtuber.carrd.co/#ref",
          image_urls: %w[
            https://silvivtuber.carrd.co/assets/images/image06.jpg
            https://silvivtuber.carrd.co/assets/images/image14.png
          ],
          media_files: [
            { file_size: 399_974 },
            { file_size: 2_441_132 },
          ],
          page_url: "https://silvivtuber.carrd.co/#ref",
          profile_url: "https://silvivtuber.carrd.co",
          profile_urls: %w[https://silvivtuber.carrd.co],
          username: "silvivtuber",
          other_names: ["silvivtuber"],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            "[image]":[https://silvivtuber.carrd.co/assets/images/image06.jpg]

            "[image]":[https://silvivtuber.carrd.co/assets/images/image14.png]

            h2. ・BLOOD SILVI ・ REFERENCE

            [b]Species:[/b] Owl
            [b]Gender:[/b] Female
            [b]Height:[/b] 5 Feet and a half inch tall (154 cm)
            [b]Birthday:[/b] March 3rd
            [b]Body Type:[/b] Slender
            [b]Eye Color:[/b] Red Orange glow with purple undertone
            [b]Hair Color:[/b] Black with red under hair and a red streak on their bangs

            [b][ Notes][/b]
            ✧ Flat chested
            ✧ Tattoo on front of right thigh
            ✧ Elf ears with earrings along the top
            ✧ Bandages on her right arm, usually wields scythe with this arm[b][Personality][/b]
            Haughty, evil and domineering! She will demand the world of you and more! You will submit to her or you will be punished! She is also messy and lazy, will not do chores on her own! Always covered in blood for some reason! Chuunibyou tendencies.
          EOS
        )
      end

      context "A crd.co page" do
        strategy_should_work(
          "https://popuru.crd.co/#illustration",
          image_urls: %w[
            https://popuru.crd.co/assets/images/gallery01/0a55b9f2_original.jpg
            https://popuru.crd.co/assets/images/gallery01/5e8d0711_original.jpg
            https://popuru.crd.co/assets/images/gallery01/0501db00_original.jpg
            https://popuru.crd.co/assets/images/gallery01/e54a6ffe_original.jpg
            https://popuru.crd.co/assets/images/gallery01/5c0c81b5_original.jpg
          ],
          media_files: [
            { file_size: 90_888 },
            { file_size: 118_584 },
            { file_size: 210_944 },
            { file_size: 164_972 },
            { file_size: 197_111 },
          ],
          page_url: "https://popuru.crd.co/#illustration",
          profile_url: "https://popuru.crd.co",
          profile_urls: %w[https://popuru.crd.co],
          display_name: nil,
          username: "popuru",
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: <<~EOS.chomp
            h1. [b]PEDRO SCHMIDT[/b]

            h2. 2d animation and storyboard

            "[email protected]":[https://popuru.crd.co/cdn-cgi/l/email-protection]

            * "[image]":[https://popuru.crd.co/assets/images/gallery01/0a55b9f2_original.jpg]
            * "[image]":[https://popuru.crd.co/assets/images/gallery01/5e8d0711_original.jpg]
            * "[image]":[https://popuru.crd.co/assets/images/gallery01/0501db00_original.jpg]
            * "[image]":[https://popuru.crd.co/assets/images/gallery01/e54a6ffe_original.jpg]
            * "[image]":[https://popuru.crd.co/assets/images/gallery01/5c0c81b5_original.jpg]
          EOS
        )
      end

      context "For a custom domain:" do
        context "A page URL" do
          strategy_should_work(
            "https://hyphensam.com/#test-image",
            image_urls: %w[https://hyphensam.com/assets/images/image04.jpg],
            media_files: [{ file_size: 14_413 }],
            page_url: "https://hyphensam.com/#test-image",
            profile_url: "https://hyphensam.com",
            profile_urls: %w[https://hyphensam.com],
            username: nil,
            other_names: [],
            tags: [],
            dtext_artist_commentary_title: "",
            dtext_artist_commentary_desc: <<~EOS.chomp
              "[image]":[https://hyphensam.com/assets/images/image04.jpg]

              Test text blah blah blah
            EOS
          )
        end

        context "An image URL with a referer" do
          strategy_should_work(
            "https://hyphensam.com/assets/images/image04.jpg?v=2cc95429",
            referer: "https://hyphensam.com/#test-image",
            image_urls: %w[https://hyphensam.com/assets/images/image04.jpg],
            media_files: [{ file_size: 14_413 }],
            page_url: "https://hyphensam.com/#test-image",
            profile_url: "https://hyphensam.com",
            profile_urls: %w[https://hyphensam.com],
            username: nil,
            other_names: [],
            tags: [],
            dtext_artist_commentary_title: "",
            dtext_artist_commentary_desc: <<~EOS.chomp
              "[image]":[https://hyphensam.com/assets/images/image04.jpg]

              Test text blah blah blah
            EOS
          )
        end

        context "An image URL without a referer" do
          strategy_should_work(
            "https://hyphensam.com/assets/images/image04.jpg?v=2cc95429",
            image_urls: %w[https://hyphensam.com/assets/images/image04.jpg?v=2cc95429],
            media_files: [{ file_size: 14_413 }],
            page_url: nil,
            profile_url: nil
          )
        end
      end

      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://rosymiz.carrd.co/assets/images/gallery01/1a19b400.jpg?v=c6f079b5"))
        assert(Source::URL.image_url?("https://popuru.crd.co/assets/images/gallery01/0a55b9f2_original.jpg?v=ea05d439"))

        assert(Source::URL.page_url?("https://caminukai-art.carrd.co/#fanart-shadowheartguidance"))
        assert(Source::URL.page_url?("https://caminukai-art.carrd.co/#home"))
        assert(Source::URL.page_url?("https://otonokj.crd.co/#info"))

        assert(Source::URL.profile_url?("https://caminukai-art.carrd.co"))
        assert(Source::URL.profile_url?("https://caminukai-art.carrd.co#"))
        assert(Source::URL.profile_url?("https://otonokj.crd.co"))
      end
    end
  end
end
