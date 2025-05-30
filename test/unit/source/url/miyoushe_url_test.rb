require "test_helper"

module Source::Tests::URL
  class MiyousheUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://upload-bbs.miyoushe.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg",
          "https://upload-bbs.mihoyo.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg",
          "https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/3356bf88b08fdc8aaa5b5e6b26f70d23_5122589414918681540.jpg",
          "https://prod-vod-sign.miyoushe.com/ooKvbeTisEJIQWJ35PqPsGMFC9iyz4h1gQzAAN?auth_key=1716561874-d87f81457c-0-fdd0dd6514dd0e6f612a312448908500",
          "https://act-upload.mihoyo.com/sr-wiki/2023/12/12/279865110/71407be63242f3b5ef6c73cbd12a4d0b_708709569307330375.png",
          "https://webstatic.mihoyo.com/upload/event/2023/08/10/40131b779e708c2f9f464ea7424e8773_4631307118561606922.jpg",
        ],
        page_urls: [
          "https://bbs.mihoyo.com/bh3/article/28939887",
          "https://www.miyoushe.com/bh3/article/28939887",
          "https://m.bbs.mihoyo.com/bh3?channel=miyousheluodi%2F#/article/27266673",
          "https://m.miyoushe.com/bh3?channel=miyousheluodi%2F#/article/27266673",
          "https://www.hoyolab.com/article/14554718",
          "https://m.hoyolab.com/#/article/28583736?utm_source=sns&utm_medium=twitter&utm_id=2",
        ],
        profile_urls: [
          "https://bbs.mihoyo.com/bh3/accountCenter/postList?id=73731802",
          "https://www.miyoushe.com/bh3/accountCenter/postList?id=73731802",
          "https://www.miyoushe.com/sr/accountCenter/replyList?id=73731802",
          "https://m.miyoushe.com/bh3/#/accountCenter/0?id=275785895",
          "https://www.hoyolab.com/accountCenter/postList?id=58551199",
        ],
      )
    end
  end
end
