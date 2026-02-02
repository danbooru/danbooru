require "test_helper"

module Source::Tests::Extractor
  class FandomExtractorTest < ActiveSupport::ExtractorTestCase
    context "A sample image URL" do
      strategy_should_work(
        "https://static.wikia.nocookie.net/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png/revision/latest/scale-to-width-down/1000?cb=20130523100711",
        image_urls: %w[https://static.wikia.nocookie.net/typemoon/images/9/96/Caster_Extra_Takeuchi_design_1.png?format=original],
        media_files: [{ file_size: 6_085_628 }],
        page_url: "https://typemoon.fandom.com/wiki/File:Caster_Extra_Takeuchi_design_1.png",
        profile_urls: %w[https://typemoon.fandom.com/wiki/User:Nikonu],
        display_name: nil,
        username: "Nikonu",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A UUID image URL" do
      strategy_should_work(
        "https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81/thumbnail/width/400/height/400",
        image_urls: %w[https://static.wikia.nocookie.net/74a9f058-f816-4856-8aad-c398aa8a4c81?format=original],
        media_files: [{ file_size: 1_021_260 }],
        page_url: nil,
        profile_urls: [],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A wiki.fandom.com/wiki/:page?file=:file URL" do
      strategy_should_work(
        "https://kancolle.fandom.com/Mutsuki?file=Mutsuki_Full.png",
        image_urls: %w[https://static.wikia.nocookie.net/kancolle/images/3/3b/Mutsuki_Full.png?format=original],
        media_files: [{ file_size: 135_822 }],
        page_url: "https://kancolle.fandom.com/wiki/Mutsuki?file=Mutsuki_Full.png",
        profile_urls: %w[https://kancolle.fandom.com/wiki/User:Botkaze],
        display_name: nil,
        username: "Botkaze",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          id = 1
          name = 睦月
          type = full
          size = 135822
          last-modified = 1534498093000
          sha1 = f12aefe0159aabc91c18f906864ff0f7e6787d23
          url = <http://203.104.209.55/kcs2/resources/ship/full/0001_5865.png>
        EOS
      )
    end

    context "A wiki.fandom.com/wiki/:page?file=:file URL that is a Youtube video" do
      strategy_should_work(
        "https://typemoon.fandom.com/wiki/Kara_no_Kyoukai_-_The_Garden_of_sinners_Movie_4:_The_Hollow_Shrine?file=The_Garden_of_sinners_Chapter_4_Preview",
        image_urls: [],
        page_url: "https://typemoon.fandom.com/wiki/Kara_no_Kyoukai_-_The_Garden_of_sinners_Movie_4:_The_Hollow_Shrine?file=The_Garden_of_sinners_Chapter_4_Preview",
        profile_urls: %w[https://typemoon.fandom.com/wiki/User:Nikonu],
        display_name: nil,
        username: "Nikonu",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          h2. Description

          Category: Film
        EOS
      )
    end

    context "A wiki.fandom.com/wiki/File:name URL" do
      strategy_should_work(
        "https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png",
        image_urls: %w[https://static.wikia.nocookie.net/typemoon/images/2/2f/Memories_of_Trifas.png?format=original],
        media_files: [{ file_size: 450_447 }],
        page_url: "https://typemoon.fandom.com/wiki/File:Memories_of_Trifas.png",
        profile_urls: %w[https://typemoon.fandom.com/wiki/User:Lemostr00],
        display_name: nil,
        username: "Lemostr00",
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "File uploaded with MsUpload",
      )
    end

    context "A wiki page" do
      strategy_should_work(
        "https://typemoon.fandom.com/wiki/Tamamo-no-Mae",
        image_urls: [],
        media_files: [],
        page_url: "https://typemoon.fandom.com/wiki/Tamamo-no-Mae",
        profile_urls: %w[https://typemoon.fandom.com],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A deleted or nonexistent wiki file" do
      strategy_should_work(
        "https://kancolle.fandom.com/wiki/File:bad.png",
        image_urls: [],
        page_url: "https://kancolle.fandom.com/wiki/File:bad.png",
        profile_urls: %w[https://kancolle.fandom.com],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end

    context "An invalid wiki file" do
      strategy_should_work(
        "https://sonic.fandom.com/wiki/File:Shadow_the_Hedgehog_2015.png https://static.wikia.nocookie.net/sonic/images/6/6c/Shadow_the_Hedgehog_2015.png",
        image_urls: [],
        page_url: "https://sonic.fandom.com/wiki/File:Shadow_the_Hedgehog_2015.png%2520https:%2Fstatic.wikia.nocookie.net%2Fsonic%2Fimages%2F6%2F6c%2FShadow_the_Hedgehog_2015.png",
        profile_urls: %w[https://sonic.fandom.com],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
