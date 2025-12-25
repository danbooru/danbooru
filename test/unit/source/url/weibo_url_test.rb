require "test_helper"

module Source::Tests::URL
  class WeiboUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "http://ww1.sinaimg.cn/large/69917555gw1f6ggdghk28j20c87lbhdt.jpg",
          "http://ww4.sinaimg.cn/mw690/77a2d531gw1f4u411ws3aj20m816fagg.jpg",
          "https://wx4.sinaimg.cn/orj360/e3930166gy1g546bz86cij20u00u040y.jpg",
          "https://wx1.sinaimg.cn/original/7004ec1cly1ge9dcbsw4lj20jg2ir7wh.jpg",
          "https://f.video.weibocdn.com/o0/wPhyi3dIlx086mr8Md3y01041200xT4N0E010.mp4?label=mp4_1080p&template=1080x1920.24.0&media_id=4914351942074379&tp=8x8A3El:YTkl0eM8&us=0&ori=1&bf=4&ot=v&ps=3lckmu&uid=3ZoTIp&ab=,3601-g32,8143-g0,8013-g0,3601-g32,3601-g37&Expires=1716316057&ssig=uW43Bg6Lo1&KID=unistore,video",
          "https://f.us.sinaimg.cn/003K8vB7lx07rz92ubWg010412002UHB0E010.mp4?label=mp4_1080p&template=1920x1080.20.0&media_id=4339747921802209&tp=8x8A3El:YTkl0eM8&us=0&ori=1&bf=4&ot=h&lp=00002g58dE&ps=mZ6WB&uid=zszavag&ab=13038-g0,&Expires=1716411960&ssig=qmkXwFd%2B1m&KID=unistore,video",
        ],
        page_urls: [
          "http://tw.weibo.com/1300957955/3786333853668537",
          "http://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t",
          "http://weibo.com/3357910224/EEHA1AyJP",
          "https://www.weibo.com/5501756072/IF9fugHzj?from=page_1005055501756072_profile&wvr=6&mod=weibotime",
          "https://www.weibo.com/detail/4676597657371957",
          "https://m.weibo.cn/detail/4506950043618873",
          "https://m.weibo.cn/status/J33G4tH1B",
        ],
        profile_urls: [
          "https://www.weibo.com/u/5501756072",
          "https://m.weibo.cn/u/5501756072",
          "https://m.weibo.cn/profile/5501756072",
          "https://www.weibo.com/p/1005055399876326",
          "https://www.weibo.com/5501756072",
          "https://www.weibo.com/endlessnsmt",
          "https://www.weibo.com/4ubergine/photos",
          "https://www.weibo.com/n/小小男爵不要坑",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "https://weibo.com/u/",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://www.weibo.com/3150932560/H4cFbeKKA?from=page_1005053150932560_profile&wvr=6&mod=weibotime",
                             page_url: "https://www.weibo.com/3150932560/H4cFbeKKA",)

      url_parser_should_work("https://photo.weibo.com/2125874520/wbphotos/large/mid/4242129997905387/pid/7eb64558ly1friyzhj44lj20dw2qxe81",
                             page_url: "https://m.weibo.cn/detail/4242129997905387",)

      url_parser_should_work("https://m.weibo.cn/status/4173757483008088?luicode=20000061&lfid=4170879204256635",
                             page_url: "https://m.weibo.cn/status/4173757483008088",)

      url_parser_should_work("https://tw.weibo.com/SEINEN/4098035921690224",
                             page_url: "https://m.weibo.cn/detail/4098035921690224",)
    end
  end
end
