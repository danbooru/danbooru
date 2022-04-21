require "test_helper"

module Sources
  class BoothTest < ActiveSupport::TestCase
    context "A booth post" do
      images = %w[
        https://booth.pximg.net/a212cd73-75ab-482d-8fce-1ce2965e4d4f/i/3713604/ae0fdbcf-e4c5-4840-8d5c-43e18bddc93e.jpg
        https://booth.pximg.net/a212cd73-75ab-482d-8fce-1ce2965e4d4f/i/3713604/d12bce50-a0c7-43f8-a4fb-5ee0ea6855a3.jpg
        https://booth.pximg.net/a212cd73-75ab-482d-8fce-1ce2965e4d4f/i/3713604/f5332da3-4097-4d33-bbf6-a9b64c7671b3.jpg
      ]
      strategy_should_work(
        "https://booth.pm/en/items/3713604",
        image_urls: images,
        profile_url: "https://amedamacon.booth.pm",
        page_url: "https://booth.pm/en/items/3713604",
        artist_name: "amedamacon",
        other_names: ["あめうさぎBOOTH"],
        tags: [["抱き枕カバー", "https://booth.pm/en/browse/Pillow%20Cover?tags%5B%5D=%E6%8A%B1%E3%81%8D%E6%9E%95%E3%82%AB%E3%83%90%E3%83%BC"]],
        artist_commentary_title: "フユちゃん抱き枕カバー",
        dtext_artist_commentary_desc: /発送：6月上旬頃（BOOTH倉庫より発送）/
      )
    end

    context "A booth image" do
      strategy_should_work(
        "https://booth.pximg.net/a212cd73-75ab-482d-8fce-1ce2965e4d4f/i/3713604/d12bce50-a0c7-43f8-a4fb-5ee0ea6855a3_base_resized.jpg",
        image_urls: ["https://booth.pximg.net/a212cd73-75ab-482d-8fce-1ce2965e4d4f/i/3713604/d12bce50-a0c7-43f8-a4fb-5ee0ea6855a3.jpg"],
        profile_url: "https://amedamacon.booth.pm",
        page_url: "https://booth.pm/en/items/3713604",
        artist_name: "amedamacon",
        other_names: ["あめうさぎBOOTH"],
        tags: [["抱き枕カバー", "https://booth.pm/en/browse/Pillow%20Cover?tags%5B%5D=%E6%8A%B1%E3%81%8D%E6%9E%95%E3%82%AB%E3%83%90%E3%83%BC"]],
        artist_commentary_title: "フユちゃん抱き枕カバー",
        dtext_artist_commentary_desc: /発送：6月上旬頃（BOOTH倉庫より発送）/
      )
    end

    context "A booth post with artist name in the url" do
      strategy_should_work(
        "https://re-face.booth.pm/items/2423989",
        image_urls: ["https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2423989/a692d4f3-4371-4a86-a337-83fee82d46a4.png"],
        profile_url: "https://re-face.booth.pm",
        page_url: "https://booth.pm/en/items/2423989",
        artist_name: "re-face",
        other_names: ["Re:fAce/りふぇいす。"],
        tags: ["original"],
        artist_commentary_title: "RwithV vol.1 -アイドルはじめます！-",
        dtext_artist_commentary_desc: /注文が殺到した際は、発送が遅れてしまう場合もございますので予めご了承ください。/
      )
    end

    context "A profile background picture" do
      strategy_should_work(
        "https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638_base_resized.jpg",
        image_urls: ["https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.png"],
        profile_url: nil
      )
    end

    context "A profile icon" do
      strategy_should_work(
        "https://booth.pximg.net/c/128x128/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314_base_resized.jpg",
        image_urls: ["https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.png"],
        profile_url: nil
      )
    end

    context "A non-existing or deleted post" do
      strategy_should_work("https://booth.pm/en/items/2003079", deleted: true)
    end
  end
end
