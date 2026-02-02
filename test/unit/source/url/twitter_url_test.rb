require "test_helper"

module Source::Tests::URL
  class TwitterUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:small",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=900x900",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=orig",
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/600x200",
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/1500x500",
          "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg",
          "https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg",
          "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg",
        ],
        image_samples: [
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:small",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=900x900",
          "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg",
          "https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg",
          "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg",
          "https://pbs.twimg.com/profile_images/1425792004877733891/UM8s9d2x_400x400.png",
          "https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs_normal.jpeg",
          "https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs_400x400.jpeg",
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/600x200",
        ],
        page_urls: [
          "https://twitter.com/i/status/1261877313349640194",
          "https://twitter.com/i/web/status/1261877313349640194",
          "https://twitter.com/BOW999/status/1261877313349640194",
          "https://twitter.com/BOW999/statuses/1261877313349640194",
          "https://twitter.com/BOW999/status/1261877313349640194/photo/1",
          "https://twitter.com/BOW999/status/1261877313349640194?s=19",
          "https://twitter.com/@BOW999/status/1261877313349640194",
          "https://x.com/i/status/1261877313349640194",
          "https://x.com/i/web/status/1261877313349640194",
          "https://x.com/BOW999/status/1261877313349640194",
          "https://x.com/BOW999/statuses/1261877313349640194",
          "https://vxtwitter.com/i/status/1261877313349640194",
          "https://vxtwitter.com/i/web/status/1261877313349640194",
          "https://vxtwitter.com/@BOW999/status/1261877313349640194",
          "https://fxtwitter.com/i/status/1261877313349640194",
          "https://fxtwitter.com/i/web/status/1261877313349640194",
          "https://fxtwitter.com/@BOW999/status/1261877313349640194",
        ],
        profile_urls: [
          "https://www.twitter.com/irt_5433",
          "https://www.twitter.com/@irt_5433",
          "https://www.twitter.com/irt_5433/likes",
          "https://twitter.com/intent/user?user_id=1485229827984531457",
          "https://twitter.com/intent/user?screen_name=ryuudog_NFT",
          "https://twitter.com/i/user/889592953",
          "https://x.com/irt_5433",
          "https://x.com/intent/user?user_id=1485229827984531457",
          "https://x.com/intent/user?screen_name=ryuudog_NFT",
          "https://x.com/i/user/889592953",
          "https://vxtwitter.com/irt_5433",
          "https://vxtwitter.com/intent/user?user_id=1485229827984531457",
          "https://vxtwitter.com/intent/user?screen_name=ryuudog_NFT",
          "https://vxtwitter.com/i/user/889592953",
          "https://fxtwitter.com/irt_5433",
          "https://fxtwitter.com/intent/user?user_id=1485229827984531457",
          "https://fxtwitter.com/intent/user?screen_name=ryuudog_NFT",
          "https://fxtwitter.com/i/user/889592953",
        ],
      )

      should_not_find_false_positives(
        image_samples: [
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig",
          "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=orig",
          "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:orig",
          "https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg:orig",
          "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:orig",
          "https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs.jpeg",
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/1500x500",
          "https://twitter.com/i/status/1261877313349640194",
        ],
        profile_urls: [
          "https://twitter.com/home",
          "https://t.co/Dxn7CuVErW",
          "https://pic.twitter.com/Dxn7CuVErW",
        ],
        bad_links: [
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
          "https://twitter.com/merry_bongbong/header_photo",
        ],
        bad_sources: [
          "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
          "https://twitter.com/merry_bongbong/header_photo",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://twitter.com/i/status/1261877313349640194", username: nil)
      url_parser_should_work("https://twitter.com/i/web/status/1261877313349640194", username: nil)
      url_parser_should_work("https://t.co/Dxn7CuVErW", username: nil)
      url_parser_should_work("https://pic.twitter.com/Dxn7CuVErW", username: nil)
      url_parser_should_work("https://twitter.com/BOW999/status/1261877313349640194", username: "BOW999")
      url_parser_should_work("https://twitter.com/@BOW999/status/1261877313349640194", username: "BOW999")
      url_parser_should_work("https://twitter.com/@BOW999", username: "BOW999")
      url_parser_should_work("https://fixvx.com/BOW999/status/1261877313349640194",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)

      url_parser_should_work("https://fixupx.com/BOW999/status/1261877313349640194",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)

      url_parser_should_work("https://twittpr.com/BOW999/status/1261877313349640194",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)

      url_parser_should_work("https://fxtwitter.com/BOW999/status/1261877313349640194.jpg",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)

      url_parser_should_work("https://nitter.net/BOW999/status/1261877313349640194",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)

      url_parser_should_work("https://nitter.poast.org/BOW999/status/1261877313349640194",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)

      url_parser_should_work("https://xcancel.com/BOW999/status/1261877313349640194",
                             page_url: "https://twitter.com/BOW999/status/1261877313349640194",)
    end
  end
end
