require "test_helper"

module Source::Tests::URL
  class TwitterUrlTest < ActiveSupport::TestCase
    context "Twitter URLs" do
      should be_image_url(
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
        "https://pbs.twimg.com/ad_img/1415875929608396801/pklSzcPz?format=jpg&name=small",
      )

      should be_image_sample(
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
      )

      should be_page_url(
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
      )

      should be_profile_url(
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
      )

      should_not be_image_sample(
        "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig",
        "https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=orig",
        "https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:orig",
        "https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg:orig",
        "https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:orig",
        "https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs.jpeg",
        "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/1500x500",
        "https://twitter.com/i/status/1261877313349640194",
      )

      should_not be_page_url(
        "https://twitter.com/home",
        "https://t.co/Dxn7CuVErW",
        "https://pic.twitter.com/Dxn7CuVErW",
      )

      should_not be_bad_link(
        "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
        "https://twitter.com/merry_bongbong/header_photo",
      )

      should_not be_bad_source(
        "https://pbs.twimg.com/profile_banners/780804311529906176/1475001696",
        "https://twitter.com/merry_bongbong/header_photo",
      )

      should parse_url("https://twitter.com/i/status/1261877313349640194").into(username: nil)
      should parse_url("https://twitter.com/i/web/status/1261877313349640194").into(username: nil)
      should parse_url("https://t.co/Dxn7CuVErW").into(username: nil)
      should parse_url("https://pic.twitter.com/Dxn7CuVErW").into(username: nil)
      should parse_url("https://twitter.com/BOW999/status/1261877313349640194").into(username: "BOW999")
      should parse_url("https://twitter.com/@BOW999/status/1261877313349640194").into(username: "BOW999")
      should parse_url("https://twitter.com/@BOW999").into(username: "BOW999")

      should parse_url("https://fixvx.com/BOW999/status/1261877313349640194").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://fixupx.com/BOW999/status/1261877313349640194").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://twittpr.com/BOW999/status/1261877313349640194").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://fxtwitter.com/BOW999/status/1261877313349640194.jpg").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://nitter.net/BOW999/status/1261877313349640194").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://nitter.poast.org/BOW999/status/1261877313349640194").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://xcancel.com/BOW999/status/1261877313349640194").into(
        page_url: "https://x.com/BOW999/status/1261877313349640194",
      )

      should parse_url("https://x.com/intent/favorite?tweet_id=2020838133525520807").into(
        page_url: "https://x.com/i/web/status/2020838133525520807",
      )

      should parse_url("https://x.com/intent/retweet?tweet_id=2020838133525520807").into(
        page_url: "https://x.com/i/web/status/2020838133525520807",
      )

      should parse_url("https://video.twimg.com/tweet_video/E_8lAMJUYAIyenr.mp4").into(
        parsed_date: Time.utc(2021, 8, 12, 8, 49, 57, 781_000),
      )

      should parse_url("https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/960x720/wiC1XIw8QehhL5JL.mp4?tag=12").into(
        parsed_date: Time.utc(2022, 2, 23, 18, 36, 15, 507_000),
      )

      should parse_url("https://video.twimg.com/amplify_video/1215590775364259840/vid/1280x720/wE6Ngd7-JPw5vCZP.mp4?tag=13").into(
        parsed_date: Time.utc(2020, 1, 10, 11, 6, 40, 88_000),
      )

      should parse_url("https://si0.twimg.com/profile_background_images/378800000179574457/3UC-Xcnj.jpeg").into(
        parsed_date: Time.utc(2013, 9, 14, 8, 38, 52, 463_000),
      )

      should parse_url("https://pbs-0.twimg.com/media/C9xkZf7UMAEbsf7.jpg").into(
        parsed_date: Time.utc(2017, 4, 19, 12, 10, 4, 604_000),
      )

      should parse_url("https://a2.twimg.com/profile_images/1210943186/KABABABABA.jpg").into(
        page_url: nil,
        profile_url: nil,
      )
    end
  end
end
