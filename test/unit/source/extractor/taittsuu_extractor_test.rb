require "test_helper"

module Source::Tests::Extractor
  class TaittsuuExtractorTest < ActiveSupport::ExtractorTestCase
    context "A https://taittsuu.com/users/:username/status/:id url" do
      strategy_should_work(
        "https://taittsuu.com/users/razukichi/status/9532242",
        image_urls: %w[https://files.taittsuu-media.com/taiitsus/9/9532/8609d69324245020c588483a3a6f34382b01846e4fc2dc09.jpg],
        media_files: [{ file_size: 355_895 }],
        page_url: "https://taittsuu.com/users/razukichi/status/9532242",
        profile_url: "https://taittsuu.com/users/razukichi",
        profile_urls: %w[https://taittsuu.com/users/razukichi],
        display_name: "らずきち",
        username: "razukichi",
        published_at: Time.parse("2023-09-29T14:19:47.000000Z"),
        updated_at: nil,
        tags: [
          ["タイッツーお絵描き部", "https://taittsuu.com/taiitsus/hashtags/search?query=%E3%82%BF%E3%82%A4%E3%83%83%E3%83%84%E3%83%BC%E3%81%8A%E7%B5%B5%E6%8F%8F%E3%81%8D%E9%83%A8"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          アナログでキュアシュプリーム
          #タイッツーお絵描き部
        EOS
      )
    end

    context "A post with multiple images" do
      strategy_should_work(
        "https://taittsuu.com/users/razukichi/status/8281286",
        image_urls: %w[
          https://files.taittsuu-media.com/taiitsus/8/8281/5e25cdab44714cb41a9e863456a28a4130e86cb65ec273d5.jpg
          https://files.taittsuu-media.com/taiitsus/8/8281/e11bea187ebbc95441ddadce798868bb0fccf6ac20607654.jpg
        ],
        media_files: [
          { file_size: 413_627 },
          { file_size: 421_650 },
        ],
        page_url: "https://taittsuu.com/users/razukichi/status/8281286",
        profile_url: "https://taittsuu.com/users/razukichi",
        profile_urls: %w[https://taittsuu.com/users/razukichi],
        display_name: "らずきち",
        username: "razukichi",
        published_at: Time.parse("2023-09-20T07:11:37.000000Z"),
        updated_at: nil,
        tags: [
          ["イラスト", "https://taittsuu.com/taiitsus/hashtags/search?query=%E3%82%A4%E3%83%A9%E3%82%B9%E3%83%88"],
          ["プリキュア", "https://taittsuu.com/taiitsus/hashtags/search?query=%E3%83%97%E3%83%AA%E3%82%AD%E3%83%A5%E3%82%A2"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          過去絵ランダムに上げていきます〜！
          #イラスト
          #プリキュア
        EOS
      )
    end

    context "A files.taittsuu-media.com image url" do
      strategy_should_work(
        "https://files.taittsuu-media.com/taiitsus/9/9532/8609d69324245020c588483a3a6f34382b01846e4fc2dc09.jpg",
        image_urls: %w[https://files.taittsuu-media.com/taiitsus/9/9532/8609d69324245020c588483a3a6f34382b01846e4fc2dc09.jpg],
        media_files: [{ file_size: 355_895 }],
        page_url: nil,
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
  end
end
