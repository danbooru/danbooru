require "test_helper"

module Source::Tests::Extractor
  class BehanceExtractorTest < ActiveSupport::ExtractorTestCase
    setup do
      skip "Behance cookie not configured" unless Source::Extractor::Behance.enabled?
    end

    context "A mir-s3-cdn-cf.behance.net sample image URL" do
      strategy_should_work(
        "https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg",
        image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg],
        media_files: [{ file_size: 512_696 }],
        page_url: "https://www.behance.net/gallery/97612065/SailorMoon",
        profile_urls: %w[https://www.behance.net/Kensukecreations],
        display_name: "Kensuke Creations",
        username: "Kensukecreations",
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
        dtext_artist_commentary_desc: "Sailormoon redraw challenge",
      )
    end

    context "A mir-cdn.behance.net sample image URL" do
      strategy_should_work(
        "https://mir-cdn.behance.net/v1/rendition/project_modules/1400/828dc625691931.5634a721e19dd.jpg",
        image_urls: %w[https://mir-cdn.behance.net/v1/rendition/project_modules/source/828dc625691931.5634a721e19dd.jpg],
        media_files: [{ file_size: 1_498_957 }],
        page_url: "https://www.behance.net/gallery/25691931/Bigcommerce-Marketplace",
        profile_urls: %w[https://www.behance.net/LiseTownsend],
        display_name: "Lise Townsend",
        username: "LiseTownsend",
        tags: [
          ["Marketplace", "https://www.behance.net/search/projects/Marketplace"],
          ["app store", "https://www.behance.net/search/projects/app store"],
          ["theme store", "https://www.behance.net/search/projects/theme store"],
          ["ecosystem", "https://www.behance.net/search/projects/ecosystem"],
        ],
        dtext_artist_commentary_title: "Bigcommerce Marketplace",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Designed the new Bigcommerce Marketplace - an ecosystem to showcase and purchase the best apps and e-commerce themes, hire experts and get exclusive deals and offers, improve discoverability and drive traffic to bigcommerce.com.

          The majority of web traffic to bigcommerce.com came trough the old Bigcommerce app store. With the newly combined Marketplace conversion is up, discoveribilty has increased and bounce rates has decreased.

          This Marketplace will also be launched within the Bigcommerce application, creating a seamless experience for Bigcommerce merchants across the public facing website and control panel.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/828dc625691931.5634a721e19dd.jpg]

          Bigcommerce Marketplace

          I was responsible for the visual design and art direction of the newly launched Bicgommerce Marketplace,
          from concepting to finished product.

          The marketplace is an ecosystem to showcase and purchase the best apps and e-commerce themes, hire experts and get exclusive deals and offers, improve discoverability and drive traffic to bigcommerce.com.

          This Marketplace will also be launched within the Bigcommerce application,
          creating a seamless experience for Bigcommerce merchants across the public facing website and control panel.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/249ce725691931.5634a6d60881d.png]

          Apps & Integrations Category Page

          The majority of web traffic to bigcommerce.com came trough the Bigcommerce app store.
          Creating a unified marketplace with a prominent navigation system has improved discoverbilty accross the offerings, increased conversion rates and decreased bounce rates.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/9e81bc25691931.5634a6d5ee11a.png]

          App Detail Page

          Here you can find more information about the app and read reviews. Adding a strong call-to-action to install the app or start a free trial with Bigcommerce has shown an increased on conversion.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/62321025691931.5634a6d601002.png]

          Theme Landing Page

          Ecommerce themes are displayed at a larger size and can be filtered according to the top requested features and industries.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/39bb6625691931.5634a6d62de27.png]

          Theme Detail Page

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/7a57df25691931.5634a6d61a9a9.png]

          Partner Services Landing Page

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/16c4df25691931.5634a6d612837.png]

          Partner Services Category Page

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/6a85f025691931.5634a6d60e153.png]

          Offers Landing Page

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/4318ed25691931.5634a6d622bfc.png]
        EOS
      )
    end

    context "A Behance full image URL" do
      strategy_should_work(
        "https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg",
        image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg],
        media_files: [{ file_size: 512_696 }],
        page_url: "https://www.behance.net/gallery/97612065/SailorMoon",
        profile_urls: %w[https://www.behance.net/Kensukecreations],
        display_name: "Kensuke Creations",
        username: "Kensukecreations",
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
        dtext_artist_commentary_desc: "Sailormoon redraw challenge",
      )
    end

    context "A Behance post with a single image" do
      strategy_should_work(
        "https://www.behance.net/gallery/97612065/SailorMoon",
        image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg],
        media_files: [{ file_size: 512_696 }],
        page_url: "https://www.behance.net/gallery/97612065/SailorMoon",
        profile_urls: %w[https://www.behance.net/Kensukecreations],
        display_name: "Kensuke Creations",
        username: "Kensukecreations",
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
        dtext_artist_commentary_desc: "Sailormoon redraw challenge",
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
        profile_urls: %w[https://www.behance.net/AdamWorks],
        display_name: "Adam Rufino",
        username: "AdamWorks",
        tags: [
          ["evangelion", "https://www.behance.net/search/projects/evangelion"],
          ["eva01", "https://www.behance.net/search/projects/eva01"],
          ["neon genesis evangelion", "https://www.behance.net/search/projects/neon genesis evangelion"],
          ["anime", "https://www.behance.net/search/projects/anime"],
          ["engraving", "https://www.behance.net/search/projects/engraving"],
        ],
        dtext_artist_commentary_title: "The Revelation",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Homage to Neon Genesis Evangelion

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/e9798082080397.5d12a9ee55be6.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/8bb1e482080397.5d12a9ee55918.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/7a634182080397.5d12a9ee56180.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/355c6b82080397.5d12a9ee55e92.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/e2368f82080397.5d12a9ee555c0.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/4cc96982080397.5d1542e6d84cf.jpg]
          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/b875e082080397.5d1542e6d80c2.jpg]

          The Revelation

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
        profile_urls: %w[https://www.behance.net/frye],
        display_name: "John Frye",
        username: "frye",
        tags: [
          ["airship", "https://www.behance.net/search/projects/airship"],
          ["spaceship", "https://www.behance.net/search/projects/spaceship"],
          ["sketch swap", "https://www.behance.net/search/projects/sketch swap"],
          ["concept vehicle", "https://www.behance.net/search/projects/concept vehicle"],
        ],
        dtext_artist_commentary_title: "The Great Sketch Swap of 2016",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          You know those crazy "adult coloring books" that seem to be all the rage suddenly? How about some more sophisticated coloring- concept designers share their line work and render the other artist's concepts. A fantastic way to learn another designer's methods and ways of thinking!

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/d7ed8937853367.585308b103bd7.jpg]

          Dwayne Vance of course gets invited...let's see how he adds color and life to this one!

          Hopefully, this will continue, what a great idea! It started with Vaughan Ling and Christian Pearce trading line drawings to render, then Michael Kus and Lorin Wood. Now i get to participate, starting with a sketch swap with Vaughan and Lorin Wood!

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/a26c3037853367.574edf95b345f.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/14caa837853367.574e88ab754a0.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/6c88d037853367.574edf95b3aed.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/b7e09937853367.575cda0d22067.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/af33f937853367.575df9799989f.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/08afc337853367.57688f802f346.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/d2d98137853367.5851f7574b0cf.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/f28d1b37853367.5850cc1a55fdc.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/09768437853367.5775a4e15aade.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/d0aab037853367.5775a4e15a502.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/96499e37853367.5771665452014.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/efb1da37853367.577166545161c.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/2113ab37853367.585858dfb7e22.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/420e0e37853367.58913613769a0.jpg]
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
        profile_urls: %w[https://www.behance.net/ProzacGuy],
        display_name: "Prozac Guy",
        username: "ProzacGuy",
        tags: [
          ["Digital Art ", "https://www.behance.net/search/projects/Digital Art "],
          ["digital illustration", "https://www.behance.net/search/projects/digital illustration"],
          ["Drawing ", "https://www.behance.net/search/projects/Drawing "],
          ["ilustracion", "https://www.behance.net/search/projects/ilustracion"],
        ],
        dtext_artist_commentary_title: "Street food",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A Behance post with a complex commentary" do
      strategy_should_work(
        "https://www.behance.net/gallery/148507747/Title",
        image_urls: %w[
          https://mir-s3-cdn-cf.behance.net/project_modules/source/e6820f148507747.62d6d98be7920.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/09a5f3148507747.62d76440da32d.gif
          https://mir-s3-cdn-cf.behance.net/project_modules/source/c84224148507747.62d6d98be9375.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/dc2a9b148507747.62d6d98ae4a6a.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/8e9621148507747.62d6d98ae40f1.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/df08c6148507747.62d6e0e61e904.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/371a9a148507747.62d6d98be8465.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/51682b148507747.62d76440d9aa8.gif
          https://mir-s3-cdn-cf.behance.net/project_modules/source/df5ccc148507747.62d76440d8d83.png
          https://mir-s3-cdn-cf.behance.net/project_modules/source/eb62ba148507747.62d80dffa9ed3.gif
          https://mir-s3-cdn-cf.behance.net/project_modules/source/97dce2148507747.62d6e438cf5f1.jpg
          https://mir-s3-cdn-cf.behance.net/project_modules/source/f2d1c9148507747.62d6e4387530c.jpg
          https://mir-s3-cdn-cf.behance.net/project_modules/source/890dff148507747.62d6e43874441.jpg
          https://mir-s3-cdn-cf.behance.net/project_modules/source/3f4771148507747.62d6e43874c29.jpg
          https://mir-s3-cdn-cf.behance.net/project_modules/source/da212b148507747.62d80662d622c.gif
          https://mir-s3-cdn-cf.behance.net/project_modules/source/f0b94d148507747.62d8081cd830e.gif
          https://mir-s3-cdn-cf.behance.net/project_modules/source/238bf8148507747.62d80dffa960e.gif
          https://mir-s3-cdn-cf.behance.net/project_modules/source/500d99148507747.62d76440d94be.png
        ],
        media_files: [
          { file_size: 6_556_357 },
          { file_size: 3_706_233 },
          { file_size: 13_798_358 },
          { file_size: 18_681_601 },
          { file_size: 14_117_428 },
          { file_size: 14_774_116 },
          { file_size: 13_965_615 },
          { file_size: 3_706_233 },
          { file_size: 43_779 },
          { file_size: 43_773_135 },
          { file_size: 1_605_156 },
          { file_size: 357_644 },
          { file_size: 367_100 },
          { file_size: 551_232 },
          { file_size: 33_272_580 },
          { file_size: 48_063_183 },
          { file_size: 46_235_564 },
          { file_size: 54_339 },
        ],
        page_url: "https://www.behance.net/gallery/148507747/-RAIDEN-SHOGUN",
        profile_urls: %w[https://www.behance.net/kaisoud],
        display_name: "Kaisou D",
        username: "kaisoud",
        tags: [
          ["3D", "https://www.behance.net/search/projects/3D"],
          ["anime", "https://www.behance.net/search/projects/anime"],
          ["Character", "https://www.behance.net/search/projects/Character"],
          ["cinema 4d", "https://www.behance.net/search/projects/cinema 4d"],
          ["Genshin impact", "https://www.behance.net/search/projects/Genshin impact"],
          ["modeling", "https://www.behance.net/search/projects/modeling"],
          ["octane", "https://www.behance.net/search/projects/octane"],
          ["Zbrush", "https://www.behance.net/search/projects/Zbrush"],
        ],
        dtext_artist_commentary_title: "雷電将軍 RAIDEN SHOGUN",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/e6820f148507747.62d6d98be7920.png]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/09a5f3148507747.62d76440da32d.gif]

          In July 2022, I have been wandering around social media to find new inspiration, along with playing some video games to change my mindset.

          Incidentally, I saw a post on "Tự Học 3D":[https://www.facebook.com/TuiTuHoc3D/posts/pfbid02epU3SMEyR7uvUgq1CbrNZCJp6F6X8idmemrkKw2FeFGs4Yb1XEMUtGrhU4pEyL95l] page with high quality student's work - Raiden Shogun from Genshin Impact.

          The project started when I'm commenting on that post asked for 3D file to practicing lookdev technique, suprising that the owner is interested too!

          Therefore the collaboration begin, with "2 livestream session":[https://www.facebook.com/kaisou.doan/videos/559657818969488/] on my personal Facebook account.

          Through out this project, I'm learned more about the convert process between softwares & successfully research some new techniques.

          Below are the breakdown procress & sharing my experience during creation.

          Thanks for passing by!

          -

          Tháng 07/2022, mình dạo quanh một số trang mạng xã hội để tìm cảm hứng sáng tạo, cũng như chơi một số tựa game để thay đổi mindset một tí. Tình cờ mình bắt gặp một bài viết trên trang "Tự Học 3D":[https://www.facebook.com/TuiTuHoc3D/posts/pfbid02epU3SMEyR7uvUgq1CbrNZCJp6F6X8idmemrkKw2FeFGs4Yb1XEMUtGrhU4pEyL95l] với sản phẩm của một bạn học viên rất chất lượng - Raiden Shogun từ Genshin Impact.

          Dự án bắt đầu khi mình comment xin file để luyện lookdev, và thật bất ngờ bạn cũng khá hào hứng với ý tưởng này!

          Thế là màn collab được triển khai, với "2 buổi livestream":[https://www.facebook.com/kaisou.doan/videos/559657818969488/] thực hiện trên trang Facebook cá nhân của mình.

          Qua dự án này, mình cũng học được thêm quy trình chuyển đổi file giữa nhiều phần mềm & research thành công một số kỹ thuật mới.

          Bên dưới là quá trình thực hiện cũng như kinh nghiệm mình gặt hái được khi thực hiện tác phẩm.

          Cảm ơn mọi người đã ghé thăm!

          RAIDEN SHOGUN

          A Genshin Impact Fan Art

          -

          // July 2022

          雷電将軍
          Kaisou D x Romeo Arturio
          XXMMII



          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/c84224148507747.62d6d98be9375.png]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/dc2a9b148507747.62d6d98ae4a6a.png]
          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/8e9621148507747.62d6d98ae40f1.png]
          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/df08c6148507747.62d6e0e61e904.png]

          In order to express the character attitude, I've been reading and watch several of video about Raiden Shogun with the support from Romeo which help me to bring the most out of her - from color palette to FX, facial expression & proper background.

          At first, I was planning to do material lookdev and FX compositing only to make the character look more interesting.

          But in the end, the inspiration flow through which make me push more quality into it, adding a lot of details to make the final works completely well-groomed

          -

          Để ra được khí chất của nhân vật, mình đã phải tìm hiểu và xem rất nhiều video về Raiden Shogun cũng như có sự hỗ trợ của Romeo để bám sát tính cách nhân vật nhất có thể - từ color palette cho đến FX, biểu cảm & bối cảnh phải phù hợp.

          Dự định ban đầu của mình sẽ chỉ dừng lại ở việc lookdev chất liệu và compositing một số FX để nhân vật thêm ấn tượng thôi.

          Nhưng càng về sau nguồn cảm hứng nổi lên càng nhiều buộc mình phải đẩy chất lượng lên cao hơn, thêm nhiều chi tiết nữa để tác phẩm thật sự chỉn chu.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/371a9a148507747.62d6d98be8465.png]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/51682b148507747.62d76440d9aa8.gif]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/df5ccc148507747.62d76440d8d83.png]

          Character Model is sculpted by Romeo Arturio. She using Zbrush & Maya to create the character model, then move to Subtance Painter to start painting its texture.

          -

          Model nhân vật được nặn bởi Romeo Arturio. Bạn sử dụng Zbrush & Maya để modeling, sau đó chuyển sang Subtance Painter và bắt đầu tô vẽ phần texture cho nhân vật.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/eb62ba148507747.62d80dffa9ed3.gif]

          After finish modeling phase, she rendered character out using Arnold Renderer in Maya. Despite the character model & textures was good, it's seem unlively due to poor lighting & composition, which make overall look flat and lack of depth

          -

          Sau khi modeling xong, bạn render nhân vật ra bằng Arnold Render trong Maya. Mặc dù chất lượng model & texture rất tốt, nhưng sản phẩm trông vẫn chưa thực sự sinh động do đánh sáng và bố cục chưa tốt, khiến cho tổng thể bị phẳng và thiếu chiều sâu.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/97dce2148507747.62d6e438cf5f1.jpg]

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/f2d1c9148507747.62d6e4387530c.jpg]
          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/890dff148507747.62d6e43874441.jpg]
          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/3f4771148507747.62d6e43874c29.jpg]

          To help her with the rendering, I need to bring the 3D model from Maya to Cinema 4D and use Octane Renderer for realism result.

          The problems start here: X-gen hair cannot export directly to other software in .fbx format.

          Therefore, I was done a research about X-gen conversion, and end up success generate the hair into polymesh. After that, we need to optimize those polygon to reduce chatter & file size.

          -

          Để có được độ chân thực với chất lượng cao cho render, mình cần phải mang model từ Maya sang Cinema 4D để xử lý bằng Octane Renderer.

          Và vấn đề xuất hiện: Tóc được làm từ X-gen không thể xuất trực tiếp sang các phần mềm khác dưới định dạng .fbx.

          Vì thế, mình đã có một buổi research về cách chuyển đổi file X-gen và kết quả đã chuyển được các sợi tóc sang dạng polygon. Sau khi hoàn tất, mình sẽ phải giảm số lượng polygon để tránh giật lag và giảm độ lớn của file.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/da212b148507747.62d80662d622c.gif]

          Next is the Distort-Glowing-Energy-Arms. I'm using Displacer in Cinema 4D to Distort those arms mesh, and FBM noise pattern to make the distortion form look-like energy heat. After that, apply Emission Material with Falloff Opacity will make it energy feel like.

          -

          Tiếp theo là hiệu ứng của cánh tay phát sáng. Mình sử dụng Displacer để làm biến dạng lưới của cánh tay, dùng Noise dạng FBM để hình dáng khi bị displace sẽ trông giống nhiệt lượng hơn. Sau đó chỉ việc áp material dạng phát sáng và cho trong suốt ở giữa, chỉ phát sáng phần viền là tạo ra được hiệu ứng năng lượng ngay.

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/f0b94d148507747.62d8081cd830e.gif]

          For the Thunder Stroke FX, I'm using Python & Xpresso to make procedural trail, then apply Tracer to generate mesh from those Spline.

          -

          Với hiệu ứng tia sét, mình sử dụng Python & Xpresso để tạo các đường Spline procedural có thể thay đổi được hình dạng, sau đó dùng hiệu ứng Tracer để tạo mesh từ các đường Spline đó

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/238bf8148507747.62d80dffa960e.gif]

          When I'm happy with the result in Cinema 4D, I'm render them out and start compositing in After Effects to add more details & displacement to final images. Then, I took them in Photoshop to touch up a little bit and remove some glitches.

          More in-depth process in the Breakdown video, please take a look and leave a comment below.

          Thank you for your appreciation !

          -

          Khi mình đã hài lòng với kết quả trong Cinema 4D, mình render tất cả ra dưới định dạng .EXR và chuyển sang After Effects để composite thêm chi tiết & hiệu ứng nhiễu cho các cánh tay để hoàn thiện tác phẩm. Cuối cùng, mình đưa các hình ảnh đó vào Photoshop để đánh khối thêm và xoá một vài lỗi render.

          Chi tiết về quá trình thực hiện mọi người có thể xem ở video Breakdown sau đây và để lại một bình luận nhận xét bên dưới nhé

          Cảm ơn mọi người đã ủng hộ !

          <https://www.youtube.com/embed/9CLOXoe7v3Q>

          Credit:

          Sculpting / Modeling: Romeo Arturio

          Texturing: Romeo Arturio

          Lighting, Material, Rendering: Kaisou D

          VFX Compositing: Kaisou D

          Software: Zbrush, Maya, Subtance Painter, Cinema 4D, Octane Render, Adobe Photoshop, After Effects

          -

          Romeo Arturio

          "FACEBOOK":[https://www.facebook.com/nbaongoc1102] | "ART STATION":[https://www.artstation.com/romeoarturio]| "TWITTER":[https://twitter.com/RomeoArthur1412]

          romeoarthur1412@gmail.com

          Kaisou D

          "INSTAGRAM":[https://www.instagram.com/kaisoud/] | "FACEBOOK ":[https://www.facebook.com/KaisouD1/] | " VIMEO":[https://vimeo.com/kaisoud]

          kaisou.doan@gmail.com

          "[image]":[https://mir-s3-cdn-cf.behance.net/project_modules/source/500d99148507747.62d76440d94be.png]
        EOS
      )
    end

    context "A NSFW Behance post" do
      strategy_should_work(
        "https://www.behance.net/gallery/10784599/The-Garden",
        image_urls: %w[https://mir-s3-cdn-cf.behance.net/project_modules/source/a247f410784599.560eb10242efc.jpg],
        media_files: [{ file_size: 492_667 }],
        page_url: "https://www.behance.net/gallery/10784599/The-Garden",
        profile_urls: %w[https://www.behance.net/absolum],
        display_name: "Alejandro Tio",
        username: "absolum",
        tags: [
          ["The Garden", "https://www.behance.net/search/projects/The Garden"],
          ["Flowers", "https://www.behance.net/search/projects/Flowers"],
          ["sketchbook", "https://www.behance.net/search/projects/sketchbook"],
          ["women", "https://www.behance.net/search/projects/women"],
        ],
        dtext_artist_commentary_title: "The Garden",
        dtext_artist_commentary_desc: "sketchbook illustration",
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
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
