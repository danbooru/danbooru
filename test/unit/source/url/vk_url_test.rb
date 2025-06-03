require "test_helper"

module Source::Tests::URL
  class VkUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://sun9-69.userapi.com/impg/VJBWV0vYZJLRhFBkQxaVtVo9_givXP6BycJJow/RBoOQ0nHMNc.jpg?size=1200x1600&quality=96&sign=73e562b2f74629cba714f7a348d0e815&type=album",
        ],
        page_urls: [
          "https://vk.com/wall-185765571_2635",
          "https://vk.com/wall194141788_4201",
          "https://vk.com/photo-185765571_457240497?list=album-185765571_00",
          "https://vk.com/public191516762?w=wall-191516762_2283",
          "https://vk.com/enigmasblog?w=wall-185765571_2636",
          "https://vk.com/sgips?z=album-111670353_227001377",
          "https://vk.com/sgips?z=photo-111670353_457285023%2Fwall-111670353_64279",
          "https://vk.com/the.dark.mangaka?z=video-162468097_456239018%2Fvideos-162468097%2Fpl_-162468097_-2",
          "https://vk.com/@sgips-tri-istorii-o-lovce",
        ],
        profile_urls: [
          "https://vk.com/wall-185765571",
          "https://vk.com/wall194141788",
          "https://vk.com/enigmasblog",
          "https://vk.com/enigmasblog/Fullart",
          "https://vk.com/video/@sgips",
          "https://vk.com/clips/sgips",
          "https://vk.com/@sgips",
          "https://vk.com/id194141788",
        ],
      )
    end
  end
end
