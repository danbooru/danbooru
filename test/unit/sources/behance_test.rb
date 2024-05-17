# frozen_string_literal: true

require "test_helper"

module Sources
  class BehanceTest < ActiveSupport::TestCase
    context "Behance:" do
      context "A mir-s3-cdn-cf.behance.net sample image URL" do
        strategy_should_work(
          "https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg",
          image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg],
          media_files: [{ file_size: 512_696 }],
          page_url: "https://www.behance.net/gallery/97612065/SailorMoon",
          profile_url: "https://www.behance.net/Kensukecreations",
          profile_urls: %w[https://www.behance.net/Kensukecreations],
          display_name: "Kensuke Creations",
          username: "Kensukecreations",
          other_names: ["Kensuke Creations", "Kensukecreations"],
          tags: [
            ["anime", "https://www.behance.net/search/projects/anime"],
            ["japanese", "https://www.behance.net/search/projects/japanese"],
            ["Kenhenslyart", "https://www.behance.net/search/projects/Kenhenslyart"],
            ["Kensukecreations", "https://www.behance.net/search/projects/Kensukecreations"],
            ["manga", "https://www.behance.net/search/projects/manga"],
            ["sailormoon", "https://www.behance.net/search/projects/sailormoon"],
            ["sailormoonanime", "https://www.behance.net/search/projects/sailormoonanime"],
            ["sailormoonredrawchallenge", "https://www.behance.net/search/projects/sailormoonredrawchallenge"],
          ],
          dtext_artist_commentary_title: "SailorMoon",
          dtext_artist_commentary_desc: "Sailormoon redraw challenge"
        )
      end

      context "A mir-cdn.behance.net sample image URL" do
        strategy_should_work(
          "https://mir-cdn.behance.net/v1/rendition/project_modules/1400/828dc625691931.5634a721e19dd.jpg",
          image_urls: %w[https://mir-cdn.behance.net/v1/rendition/project_modules/source/828dc625691931.5634a721e19dd.jpg],
          media_files: [{ file_size: 1_498_957 }],
          page_url: "https://www.behance.net/gallery/25691931/Bigcommerce-Marketplace",
          profile_url: "https://www.behance.net/LiseTownsend",
          profile_urls: %w[https://www.behance.net/LiseTownsend],
          display_name: "Lise Townsend",
          username: "LiseTownsend",
          other_names: ["Lise Townsend", "LiseTownsend"],
          tags: [
            ["Marketplace", "https://www.behance.net/search/projects/Marketplace"],
            ["app store", "https://www.behance.net/search/projects/app store"],
            ["theme store", "https://www.behance.net/search/projects/theme store"],
            ["ecosystem", "https://www.behance.net/search/projects/ecosystem"],
          ],
          dtext_artist_commentary_title: "Bigcommerce Marketplace",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Designed the new Bigcommerce Marketplace - an ecosystem to showcase and purchase the best apps and e-commerce themes, hire experts and get exclusive deals and offers, improve discoverability and drive traffic to bigcommerce.com.

            The majority of web traffic to bigcommerce.com came trough the old Bigcommerce app store. With the newly combined Marketplace conversion is up, discoveribilty has increased and bounce rates has decreased.

            This Marketplace will also be launched within the Bigcommerce application, creating a seamless experience for Bigcommerce merchants across the public facing website and control panel.
          EOS
        )
      end

      context "A Behance full image URL" do
        strategy_should_work(
          "https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg",
          image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg],
          media_files: [{ file_size: 512_696 }],
          page_url: "https://www.behance.net/gallery/97612065/SailorMoon",
          profile_url: "https://www.behance.net/Kensukecreations",
          profile_urls: %w[https://www.behance.net/Kensukecreations],
          display_name: "Kensuke Creations",
          username: "Kensukecreations",
          other_names: ["Kensuke Creations", "Kensukecreations"],
          tags: [
            ["anime", "https://www.behance.net/search/projects/anime"],
            ["japanese", "https://www.behance.net/search/projects/japanese"],
            ["Kenhenslyart", "https://www.behance.net/search/projects/Kenhenslyart"],
            ["Kensukecreations", "https://www.behance.net/search/projects/Kensukecreations"],
            ["manga", "https://www.behance.net/search/projects/manga"],
            ["sailormoon", "https://www.behance.net/search/projects/sailormoon"],
            ["sailormoonanime", "https://www.behance.net/search/projects/sailormoonanime"],
            ["sailormoonredrawchallenge", "https://www.behance.net/search/projects/sailormoonredrawchallenge"],
          ],
          dtext_artist_commentary_title: "SailorMoon",
          dtext_artist_commentary_desc: "Sailormoon redraw challenge"
        )
      end

      context "A Behance post with a single image" do
        strategy_should_work(
          "https://www.behance.net/gallery/97612065/SailorMoon",
          image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg],
          media_files: [{ file_size: 512_696 }],
          page_url: "https://www.behance.net/gallery/97612065/SailorMoon",
          profile_url: "https://www.behance.net/Kensukecreations",
          profile_urls: %w[https://www.behance.net/Kensukecreations],
          display_name: "Kensuke Creations",
          username: "Kensukecreations",
          other_names: ["Kensuke Creations", "Kensukecreations"],
          tags: [
            ["anime", "https://www.behance.net/search/projects/anime"],
            ["japanese", "https://www.behance.net/search/projects/japanese"],
            ["Kenhenslyart", "https://www.behance.net/search/projects/Kenhenslyart"],
            ["Kensukecreations", "https://www.behance.net/search/projects/Kensukecreations"],
            ["manga", "https://www.behance.net/search/projects/manga"],
            ["sailormoon", "https://www.behance.net/search/projects/sailormoon"],
            ["sailormoonanime", "https://www.behance.net/search/projects/sailormoonanime"],
            ["sailormoonredrawchallenge", "https://www.behance.net/search/projects/sailormoonredrawchallenge"],
          ],
          dtext_artist_commentary_title: "SailorMoon",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Sailormoon redraw challenge
          EOS
        )
      end

      context "A Behance post with a media gallery" do
        strategy_should_work(
          "https://www.behance.net/gallery/82080397/The-Revelation",
          image_urls: %w[
            https://mir-s3-cdn-cf.behance.net/project_modules/source/e9798082080397.5d12a9ee55be6.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/8bb1e482080397.5d12a9ee55918.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/7a634182080397.5d12a9ee56180.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/355c6b82080397.5d12a9ee55e92.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/e2368f82080397.5d12a9ee555c0.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/4cc96982080397.5d1542e6d84cf.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/b875e082080397.5d1542e6d80c2.jpg
          ],
          media_files: [
            { file_size: 338_023 },
            { file_size: 375_029 },
            { file_size: 364_335 },
            { file_size: 306_533 },
            { file_size: 1_347_797 },
            { file_size: 215_323 },
            { file_size: 387_821 },
          ],
          page_url: "https://www.behance.net/gallery/82080397/The-Revelation",
          profile_url: "https://www.behance.net/AdamWorks",
          profile_urls: %w[https://www.behance.net/AdamWorks],
          display_name: "Adam Rufino",
          username: "AdamWorks",
          other_names: ["Adam Rufino", "AdamWorks"],
          tags: [
            ["evangelion", "https://www.behance.net/search/projects/evangelion"],
            ["eva01", "https://www.behance.net/search/projects/eva01"],
            ["neon genesis evangelion", "https://www.behance.net/search/projects/neon genesis evangelion"],
            ["anime", "https://www.behance.net/search/projects/anime"],
            ["engraving", "https://www.behance.net/search/projects/engraving"],
          ],
          dtext_artist_commentary_title: "The Revelation",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Homage to Neon Genesis Evangelion
          EOS
        )
      end

      context "A Behance post with multiple owners" do
        strategy_should_work(
          "https://www.behance.net/gallery/37853367/The-Great-Sketch-Swap-of-2016",
          image_urls: %w[
            https://mir-s3-cdn-cf.behance.net/project_modules/source/d7ed8937853367.585308b103bd7.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/a26c3037853367.574edf95b345f.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/14caa837853367.574e88ab754a0.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/6c88d037853367.574edf95b3aed.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/b7e09937853367.575cda0d22067.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/af33f937853367.575df9799989f.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/08afc337853367.57688f802f346.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/d2d98137853367.5851f7574b0cf.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/f28d1b37853367.5850cc1a55fdc.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/09768437853367.5775a4e15aade.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/d0aab037853367.5775a4e15a502.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/96499e37853367.5771665452014.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/efb1da37853367.577166545161c.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/2113ab37853367.585858dfb7e22.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/420e0e37853367.58913613769a0.jpg
          ],
          media_files: [
            { file_size: 1_713_105 },
            { file_size: 1_841_143 },
            { file_size: 5_015_399 },
            { file_size: 543_793 },
            { file_size: 293_544 },
            { file_size: 1_139_068 },
            { file_size: 5_231_690 },
            { file_size: 3_500_133 },
            { file_size: 682_606 },
            { file_size: 269_903 },
            { file_size: 133_966 },
            { file_size: 3_821_243 },
            { file_size: 118_365 },
            { file_size: 388_150 },
            { file_size: 4_004_632 },
          ],
          page_url: "https://www.behance.net/gallery/37853367/The-Great-Sketch-Swap-of-2016",
          profile_url: "https://www.behance.net/frye",
          profile_urls: %w[https://www.behance.net/frye],
          display_name: "John Frye",
          username: "frye",
          other_names: ["John Frye", "frye"],
          tags: [
            ["airship", "https://www.behance.net/search/projects/airship"],
            ["spaceship", "https://www.behance.net/search/projects/spaceship"],
            ["sketch swap", "https://www.behance.net/search/projects/sketch swap"],
            ["concept vehicle", "https://www.behance.net/search/projects/concept vehicle"],
          ],
          dtext_artist_commentary_title: "The Great Sketch Swap of 2016",
          dtext_artist_commentary_desc: <<~EOS.chomp
            You know those crazy "adult coloring books" that seem to be all the rage suddenly? How about some more sophisticated coloring- concept designers share their line work and render the other artist's concepts. A fantastic way to learn another designer's methods and ways of thinking!
          EOS
        )
      end

      context "A Behance module URL" do
        strategy_should_work(
          "https://www.behance.net/gallery/157659885/Street-food/modules/889506771",
          image_urls: %w[
            https://mir-s3-cdn-cf.behance.net/project_modules/source/30927d157659885.637d0d2d2f312.jpg
            https://mir-s3-cdn-cf.behance.net/project_modules/source/0001e2157659885.637d0d2d3053c.jpg
          ],
          media_files: [
            { file_size: 2_316_195 },
            { file_size: 3_014_589 },
          ],
          page_url: "https://www.behance.net/gallery/157659885/Street-food",
          profile_url: "https://www.behance.net/ProzacGuy",
          profile_urls: %w[https://www.behance.net/ProzacGuy],
          display_name: "Prozac Guy",
          username: "ProzacGuy",
          other_names: ["Prozac Guy", "ProzacGuy"],
          tags: [
            ["Digital Art ", "https://www.behance.net/search/projects/Digital Art "],
            ["digital illustration", "https://www.behance.net/search/projects/digital illustration"],
            ["Drawing ", "https://www.behance.net/search/projects/Drawing "],
            ["ilustracion", "https://www.behance.net/search/projects/ilustracion"],
          ],
          dtext_artist_commentary_title: "Street food",
          dtext_artist_commentary_desc: ""
        )
      end

      context "A NSFW Behance post" do
        strategy_should_work(
          "https://www.behance.net/gallery/10784599/The-Garden",
          image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/a247f410784599.560eb10242efc.jpg],
          media_files: [{ file_size: 492_667 }],
          page_url: "https://www.behance.net/gallery/10784599/The-Garden",
          profile_url: "https://www.behance.net/absolum",
          profile_urls: %w[https://www.behance.net/absolum],
          display_name: "Alejandro Tio",
          username: "absolum",
          other_names: ["Alejandro Tio", "absolum"],
          tags: [
            ["The Garden", "https://www.behance.net/search/projects/The Garden"],
            ["Flowers", "https://www.behance.net/search/projects/Flowers"],
            ["sketchbook", "https://www.behance.net/search/projects/sketchbook"],
            ["women", "https://www.behance.net/search/projects/women"],
          ],
          dtext_artist_commentary_title: "The Garden",
          dtext_artist_commentary_desc: "sketchbook illustration"
        )
      end

      context "A deleted or nonexistent Behance post" do
        strategy_should_work(
          "https://www.behance.net/gallery/999999999/Test",
          image_urls: [],
          page_url: "https://www.behance.net/gallery/999999999/Test",
          profile_url: nil,
          profile_urls: %w[],
          display_name: nil,
          username: nil,
          other_names: [],
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: ""
        )
      end

      should "parse Behance URLs correctly" do
        assert(Source::URL.image_url?("https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg"))
        assert(Source::URL.image_url?("https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg"))
        assert(Source::URL.image_url?("https://mir-s3-cdn-cf.behance.net/projects/404/9d2bad97612065.Y3JvcCwxMjAwLDkzOCwyODUsMzU.jpg"))
        assert(Source::URL.image_url?("https://mir-cdn.behance.net/v1/rendition/project_modules/1400/828dc625691931.5634a721e19dd.jpg"))

        assert(Source::URL.page_url?("https://www.behance.net/gallery/97612065/SailorMoon"))
        assert(Source::URL.page_url?("https://www.behance.net/gallery/97612065/SailorMoon/modules/563634913"))

        assert(Source::URL.profile_url?("https://www.behance.net/Kensukecreations"))

        assert_equal("https://www.behance.net/gallery/97612065/Title", Source::URL.page_url("https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg"))
      end
    end
  end
end
