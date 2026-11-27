require "test_helper"

module Source::Tests::Extractor
  class CrepeExtractorTest < ActiveSupport::ExtractorTestCase
    context "A commission page with multiple images" do
      strategy_should_work(
        "https://crepe.cm/ko/@yolrsona/t71oz0uls",
        image_urls: %w[
          https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png
          https://crepe.land/commission_type/u/u0/u06v9w1pi6yu8g97u4fuoyrsq4nyoy91_%EB%9D%A0%EB%A1%B1.png
          https://crepe.land/commission_type/9/9b/9b635kxdepnt3pp7rta96hywtkvfhln5_%ED%95%9C%ED%8C%90%EB%B3%B4%EC%A0%952.png
        ],
        media_files: [
          { file_size: 5_963_288 },
          { file_size: 4_796_542 },
          { file_size: 5_485_435 },
        ],
        page_url: "https://crepe.cm/@yolrsona/t71oz0uls",
        profile_url: "https://crepe.cm/@yolrsona",
        profile_urls: %w[https://crepe.cm/@yolrsona],
        display_name: "쥑쥑버거",
        username: "yolrsona",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["그림", "https://crepe.cm/search?query=%23그림"],
          ["LD", "https://crepe.cm/search?query=%23LD"],
          ["SD", "https://crepe.cm/search?query=%23SD"],
          ["전신", "https://crepe.cm/search?query=%23전신"],
          ["2인", "https://crepe.cm/search?query=%232인"],
          ["한판", "https://crepe.cm/search?query=%23한판"],
        ],
        dtext_artist_commentary_title: "감기 조심하세요",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          가을-겨울 컨셉의 한판 타입입니다.

          [b]2인 110,000[/b]원입니다!

          마감 최대 기한은 [b]3주[/b]입니다

          컨펌은 러프에서 한 번 진행합니다!

          PNG파일 달라고 말씀 주시면 전신/밑의 얼굴SD/전신SD 드립니다~

          구도지정 의상지정 주시면 좋습니다! (오마카세도 가능이나, 캐해 보장 XX)

          색감은 그때그때 캐릭터(페어)에 맞춰 조금씩 달라질 것 같아요! 샘플 이미지 정도에서 색감 움직일듯합니다!

          BL/GL/HL/드림/유사/CP 안 가리니 많은 관심 부탁드립니다.
        EOS
      )
    end

    context "A sample image URL" do
      strategy_should_work(
        "https://i.crepe.land/https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png?h=640&q=100&t=i&v=3a&w=1280",
        image_urls: %w[https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png],
        media_files: [{ file_size: 5_963_288 }],
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

    context "A kre.pe short link" do
      strategy_should_work(
        "https://kre.pe/E0f0",
        image_urls: %w[
          https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png
          https://crepe.land/commission_type/u/u0/u06v9w1pi6yu8g97u4fuoyrsq4nyoy91_%EB%9D%A0%EB%A1%B1.png
          https://crepe.land/commission_type/9/9b/9b635kxdepnt3pp7rta96hywtkvfhln5_%ED%95%9C%ED%8C%90%EB%B3%B4%EC%A0%952.png
        ],
        page_url: "https://crepe.cm/@yolrsona/t71oz0uls",
        profile_url: "https://crepe.cm/@yolrsona",
        profile_urls: %w[https://crepe.cm/@yolrsona],
        display_name: "쥑쥑버거",
        username: "yolrsona",
        published_at: nil,
        updated_at: nil,
        tags: [
          ["그림", "https://crepe.cm/search?query=%23그림"],
          ["LD", "https://crepe.cm/search?query=%23LD"],
          ["SD", "https://crepe.cm/search?query=%23SD"],
          ["전신", "https://crepe.cm/search?query=%23전신"],
          ["2인", "https://crepe.cm/search?query=%232인"],
          ["한판", "https://crepe.cm/search?query=%23한판"],
        ],
        dtext_artist_commentary_title: "감기 조심하세요",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          가을-겨울 컨셉의 한판 타입입니다.

          [b]2인 110,000[/b]원입니다!

          마감 최대 기한은 [b]3주[/b]입니다

          컨펌은 러프에서 한 번 진행합니다!

          PNG파일 달라고 말씀 주시면 전신/밑의 얼굴SD/전신SD 드립니다~

          구도지정 의상지정 주시면 좋습니다! (오마카세도 가능이나, 캐해 보장 XX)

          색감은 그때그때 캐릭터(페어)에 맞춰 조금씩 달라질 것 같아요! 샘플 이미지 정도에서 색감 움직일듯합니다!

          BL/GL/HL/드림/유사/CP 안 가리니 많은 관심 부탁드립니다.
        EOS
      )
    end

    context "A nonexistent commission" do
      strategy_should_work(
        "https://crepe.cm/@yolrsona/doesnotexist000",
        image_urls: [],
        page_url: "https://crepe.cm/@yolrsona/doesnotexist000",
        profile_url: "https://crepe.cm/@yolrsona",
        profile_urls: %w[https://crepe.cm/@yolrsona],
        display_name: nil,
        username: "yolrsona",
        published_at: nil,
        updated_at: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "",
      )
    end
  end
end
