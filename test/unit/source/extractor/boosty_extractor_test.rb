require "test_helper"

module Source::Tests::Extractor
  class BoostyExtractorTest < ActiveSupport::ExtractorTestCase
    context "A https://boosty.to/:username/posts/:id url" do
      strategy_should_work(
        "https://boosty.to/rebeccagod/posts/8c17c3ac-30e6-4bd8-b42a-0328418581c8",
        image_urls: %w[https://images.boosty.to/image/04b6ada2-b670-403c-acce-5a8c7678087d],
        media_files: [{ file_size: 251_803 }],
        page_url: "https://boosty.to/rebeccagod/posts/8c17c3ac-30e6-4bd8-b42a-0328418581c8",
        profile_url: "https://boosty.to/rebeccagod",
        profile_urls: %w[https://boosty.to/rebeccagod],
        display_name: "REBECCA † GODDES",
        username: "rebeccagod",
        published_at: Time.parse("2026-01-29T09:18:06.000000Z"),
        updated_at: Time.parse("2026-01-29T09:18:06.000000Z"),
        tags: [],
        dtext_artist_commentary_title: "January Rewards",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Награды Января разосланы всем подписчикам! Наслаждайтесь💕

          January's rewards have been sent to all subscribers! Enjoy!
          <https://images.boosty.to/image/04b6ada2-b670-403c-acce-5a8c7678087d>
        EOS
      )
    end

    context "A post with tags and bold text" do
      strategy_should_work(
        "https://boosty.to/boosty/posts/d6ffc762-cf28-4a51-857f-6c6a6d38e564",
        image_urls: %w[
          https://images.boosty.to/image/2ab546c2-82cf-40a1-8c82-2ae241015410
          https://images.boosty.to/image/5124a468-f1db-4ea9-b547-64a53eb9ffdd
          https://images.boosty.to/image/9d6fa93f-219d-46aa-9816-746cae06345b
          https://images.boosty.to/image/1f74606a-7f72-483f-bccb-f4024e346fc3
        ],
        media_files: [
          { file_size: 1_171_948 },
          { file_size: 1_369_963 },
          { file_size: 1_411_914 },
          { file_size: 1_437_895 },
        ],
        page_url: "https://boosty.to/boosty/posts/d6ffc762-cf28-4a51-857f-6c6a6d38e564",
        profile_url: "https://boosty.to/boosty",
        profile_urls: %w[https://boosty.to/boosty],
        display_name: "Boosty",
        username: "boosty",
        published_at: Time.parse("2025-12-02T14:02:20.000000Z"),
        updated_at: Time.parse("2025-12-02T14:02:20.000000Z"),
        tags: [
          ["витрина", "https://boosty.to/boosty?postsTagsIds=66239"],
        ],
        dtext_artist_commentary_title: "Почему обложки на витрине — это важно",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          <https://images.boosty.to/image/2ab546c2-82cf-40a1-8c82-2ae241015410>
          По данным платформы, [b]большинство покупок совершается из превью витрины. [/b]Пользователь открывает профиль, бегло сканирует карточки — и за 1–2 секунды решает: открыть пост, купить или пролистать дальше.

          Грамотное изображение повышает кликабельность, вовлечённость и продажи, потому что работает как визуальный триггер и краткая презентация, объясняющая, что внутри и почему стоит открыть пост.

          [b]📌 Как работают обложки в витрине[/b]

          На витрине отображается изображение из блока[b] «Тизер поста»[/b] — именно оно становится вашей обложкой.

          Если тизер не заполнен, карточка выглядит пустой, пост теряет клики, а вместе с этим — просмотры и продажи. Даже если у видео есть собственная обложка, она не используется в витрине.

          <https://images.boosty.to/image/5124a468-f1db-4ea9-b547-64a53eb9ffdd>
          ➕[b]Как добавить обложку правильно[/b]

          ➡️ [b]Для новых постов[/b]

          1. Создайте пост.
          2. Выберите тип оплаты: разовый платеж или разовый + подписка (именно такие посты
          отображаются на витрине)
          3. Пролистайте вниз до блока «Тизер поста».
          4. Загрузите изображение-обложку.

          ➡️ [b]Для старых постов [/b]

          1. Откройте пост.
          2. Нажмите «Редактировать».
          3. Найдите блок «Тизер поста».
          4. Добавьте или замените изображение.

          🌅 [b]Рекомендации по оформлению обложек[/b]

          - Используйте квадратные изображения.
          - Размещайте текст и ключевые элементы в центре, потому что на разных устройствах края могут подрезаться.
          - Платформа автоматически масштабирует обложку под [i]575 × 625 px[/i]. Если картинка слишком вытянутая, система обрежет её.

          <https://images.boosty.to/image/9d6fa93f-219d-46aa-9816-746cae06345b>
          <https://images.boosty.to/image/1f74606a-7f72-483f-bccb-f4024e346fc3>
          Пять минут настройки — и ваш контент выглядит профессионально, аккуратно и продающе.

          [i]Пусть каждый новый посетитель увидит ваш пост именно так, как вы задумали 💛[/i]
        EOS
      )
    end

    context "A post with underlined text" do
      strategy_should_work(
        "https://boosty.to/boosty/posts/5765f1ef-735a-407b-892d-0c5ed1212f5f",
        image_urls: %w[https://images.boosty.to/image/b6f6c97c-c122-4e65-b8a3-da35ad102a71],
        media_files: [{ file_size: 126_054 }],
        page_url: "https://boosty.to/boosty/posts/5765f1ef-735a-407b-892d-0c5ed1212f5f",
        profile_url: "https://boosty.to/boosty",
        profile_urls: %w[https://boosty.to/boosty],
        display_name: "Boosty",
        username: "boosty",
        published_at: Time.parse("2020-03-26T13:55:26.000000Z"),
        updated_at: Time.parse("2022-05-23T15:47:11.000000Z"),
        tags: [],
        dtext_artist_commentary_title: "Подписка на несколько месяцев",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Этого обновления долго ждали и наконец свершилось!
          На Boosty.to появилась возможность подписаться на автора сразу на несколько месяцев, а именно: 3, 6 или 12. Оплата всей подписки списывается [u][b]СРАЗУ[/b][/u]
          <https://images.boosty.to/image/b6f6c97c-c122-4e65-b8a3-da35ad102a71>
        EOS
      )
    end

    context "A post with italic text and links" do
      strategy_should_work(
        "https://boosty.to/boosty/posts/471a4bc8-7592-474c-9cd1-607bb6d7ee7f",
        image_urls: %w[https://images.boosty.to/image/41a0eab1-0f0f-4feb-8adf-1ddb9696c568],
        media_files: [{ file_size: 135_746 }],
        page_url: "https://boosty.to/boosty/posts/471a4bc8-7592-474c-9cd1-607bb6d7ee7f",
        profile_url: "https://boosty.to/boosty",
        profile_urls: %w[https://boosty.to/boosty],
        display_name: "Boosty",
        username: "boosty",
        published_at: Time.parse("2026-05-27T13:29:25.000000Z"),
        updated_at: Time.parse("2026-05-30T11:21:35.000000Z"),
        tags: [
          ["обновления", "https://boosty.to/boosty?postsTagsIds=17620"],
          ["витрина", "https://boosty.to/boosty?postsTagsIds=66239"],
        ],
        dtext_artist_commentary_title: "ОБНОВЛЕНИЕ: Бандлы и витрина доступны в мобильном приложении RuStore",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          <https://images.boosty.to/image/41a0eab1-0f0f-4feb-8adf-1ddb9696c568>
          Если ваше приложение Boosty установлено через RuStore, теперь пользователи могут не только смотреть витрину, но и [b]покупать бандлы прямо с телефона.[/b]

          Бандлы находятся в разделе [b]«Витрина»: [/b]там можно увидеть ваши подборки, готовые наборы материалов и другие предложения.

          Что это значит для вашей аудитории:
          ➡️ удобный просмотр витрины без перехода в браузер;
          ➡️ покупка бандлов прямо в приложении;
          ➡️ быстрый доступ к подборкам, материалам и отдельным продуктам.

          ⚠️ [b]Важно: [/b]Если приложение установлено через Google Play, функция не будет активна. Чтобы получить доступ к витрине и покупке бандлов в приложении, рекомендуем удалить текущую версию и "установить Boosty через RuStore":[https://www.rustore.ru/catalog/app/to.boosty.mobile].

          Расскажите аудитории, что теперь покупать ваш контент стало ещё проще — прямо в мобильном приложении.

          [i]Это обновление доступно для пользователей из РФ.[/i]
        EOS
      )
    end

    context "A https://images.boosty.to/image/:id url" do
      strategy_should_work(
        "https://images.boosty.to/image/04b6ada2-b670-403c-acce-5a8c7678087d?change_time=1769678227&mw=545",
        image_urls: %w[https://images.boosty.to/image/04b6ada2-b670-403c-acce-5a8c7678087d],
        media_files: [{ file_size: 251_803 }],
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

    context "A paid post" do
      strategy_should_work(
        "https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
        image_urls: [],
        page_url: "https://boosty.to/rebeccagod/posts/f76e3d79-39b5-42fa-b7a1-0f8dc5261654",
        profile_url: "https://boosty.to/rebeccagod",
        profile_urls: %w[https://boosty.to/rebeccagod],
        display_name: "REBECCA † GODDES",
        username: "rebeccagod",
        published_at: Time.parse("2024-05-29T06:33:28.000000Z"),
        updated_at: Time.parse("2025-12-25T15:13:22.000000Z"),
        tags: [],
        dtext_artist_commentary_title: "Дакимакура для AniNeurax!",
        dtext_artist_commentary_desc: "",
      )
    end

    context "A post with a video" do
      expected_desc = <<~EOS.chomp
        Programs: Photoshop, After Effects, Vegas Pro
        "Tutorial. Process of creating a video.":[SIGNED_VIDEO_URL]

        I omitted some details in each program so that too many pages would not come out. I wanted to show the general process of work, not create a tutorial for each program that I use.
        ----------------------------------------------------------------------------------
        Я опустила некоторые детали в каждой программе, дабы не вышло слишком много страниц. Мне хотелось показать общий процесс работы, а не создать туториал по каждой программе, которую я использую.
        <https://images.boosty.to/image/0b7398e0-20e1-435c-8400-eb73c39e875a>
        <https://images.boosty.to/image/47d0035c-6bf2-48f8-bc5e-60558574cfd2>
        <https://images.boosty.to/image/8fe3944d-c935-4e95-86b9-d8568b4ec80d>
        Plugins:
        "Universe plugin.rar":[https://cdn.boosty.to/file/05ea7ba8-dc9b-4b2d-9fc3-d0858d86f837]
        "SapphireFX.rar":[https://cdn.boosty.to/file/08339a96-8a43-47c9-9443-b2f5bbb850d8]
      EOS

      strategy_should_work(
        "https://boosty.to/boalizard/posts/7e21d2cb-7ef9-44d4-9c45-1b07111c439f",
        image_urls: [
          %r{\Ahttps://vd\d+\.okcdn\.ru/\?expires=\d+&.*&type=5&.*&id=4610370112102\z},
          "https://images.boosty.to/image/0b7398e0-20e1-435c-8400-eb73c39e875a",
          "https://images.boosty.to/image/47d0035c-6bf2-48f8-bc5e-60558574cfd2",
          "https://images.boosty.to/image/8fe3944d-c935-4e95-86b9-d8568b4ec80d",
        ],
        media_files: [
          { file_size: 56_752_288 },
          { file_size: 2_128_302 },
          { file_size: 1_862_421 },
          { file_size: 2_340_803 },
        ],
        page_url: "https://boosty.to/boalizard/posts/7e21d2cb-7ef9-44d4-9c45-1b07111c439f",
        profile_url: "https://boosty.to/boalizard",
        profile_urls: %w[https://boosty.to/boalizard],
        display_name: "Boalizard",
        username: "boalizard",
        published_at: Time.parse("2023-06-10T12:16:55.000000Z"),
        updated_at: Time.parse("2023-08-24T21:45:34.000000Z"),
        tags: [
          ["tutorial", "https://boosty.to/boalizard?postsTagsIds=29438"],
          ["fear&hunger", "https://boosty.to/boalizard?postsTagsIds=69909"],
          ["termina", "https://boosty.to/boalizard?postsTagsIds=4304390"],
          ["video", "https://boosty.to/boalizard?postsTagsIds=4854"],
          ["art", "https://boosty.to/boalizard?postsTagsIds=83"],
          ["fanart", "https://boosty.to/boalizard?postsTagsIds=1173"],
          ["animation", "https://boosty.to/boalizard?postsTagsIds=12384"],
        ],
        dtext_artist_commentary_title: "Tutorial. Process of creating a video.",
        dtext_artist_commentary_desc: /\A#{Regexp.escape(expected_desc).sub("SIGNED_VIDEO_URL", %q{https://vd\d+\.okcdn\.ru\?\S+})}\z/,
      )
    end
  end
end
