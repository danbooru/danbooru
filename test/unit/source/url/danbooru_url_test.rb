require "test_helper"

module Source::Tests::URL
  class DanbooruUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://cdn.donmai.us/sample/8d/81/__sonetto_reverse_1999_drawn_by_beishang_yutou__sample-8d819da4871c3ca39f428999df8220ce.jpg",
          "https://cdn.donmai.us/original/8d/81/8d819da4871c3ca39f428999df8220ce.jpg",
          "https://cdn.donmai.us/8d/81/8d819da4871c3ca39f428999df8220ce.jpg",
          "https://danbooru.donmai.us/data/8d/81/8d819da4871c3ca39f428999df8220ce.jpg",
        ],
        page_urls: [
          "https://danbooru.donmai.us/posts/1",
          "https://danbooru.donmai.us/posts/1.json",
          "https://danbooru.donmai.us/posts?md5=8d819da4871c3ca39f428999df8220ce",
        ],
        profile_urls: [
          "https://danbooru.donmai.us/users/1",
          "https://danbooru.donmai.us/users/1.json",
        ],
      )
    end
  end
end
