require "test_helper"

module Source::Tests::URL
  class FacebookUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://scontent-sin1-1.xx.fbcdn.net/hphotos-xtp1/t31.0-8/11254493_576443445841777_7716273903390212288_o.jpg",
          "https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg",
        ],
        page_urls: [
          "https://www.facebook.com/photo?fbid=1362164640578443",
          "https://www.facebook.com/reel/373226486954887/",
          "https://www.facebook.com/100045011383201/posts/845746695605598",
        ],
        profile_urls: [
          "https://www.facebook.com/profile.php?id=100007366415557&name=xhp_nt__fblite__profile__tab_bar",
          "https://www.facebook.com/sinyu.tang.9",
          "https://fb.com/sinyu.tang.9",
        ],
      )

      should_not_find_false_positives(
        bad_sources: [
          "https://www.facebook.com/groups/AnatomyandAction/permalink/2647641035431143/?mibextid=Nif5oz",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://scontent-sin1-1.xx.fbcdn.net/hphotos-xtp1/t31.0-8/11254493_576443445841777_7716273903390212288_o.jpg",
                             page_url: "https://www.facebook.com/photo?fbid=576443445841777",)

      url_parser_should_work("https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg",
                             page_url: "https://www.facebook.com/photo?fbid=623015164516858",)

      url_parser_should_work("https://www.facebook.com/profile.php?id=100007366415557&name=xhp_nt__fblite__profile__tab_bar",
                             profile_url: "https://www.facebook.com/profile.php?id=100007366415557",)

      url_parser_should_work("https://www.facebook.com/profile/100007366415557",
                             profile_url: "https://www.facebook.com/profile.php?id=100007366415557",)

      url_parser_should_work("https://www.facebook.com/p/Chocotoffys-61550637164305/",
                             profile_url: "https://www.facebook.com/profile.php?id=61550637164305",)

      url_parser_should_work("https://www.facebook.com/people/Abandir/61565499492869/",
                             profile_url: "https://www.facebook.com/profile.php?id=61565499492869",)

      url_parser_should_work("https://www.facebook.com/buttersugoi2.0/posts/pfbid052HT8bQg1QzN4V8s7wouB6DEEnP9DudwpuGPtoqgUAg9WC7Ug2Z94gYXtB2S37oBl",
                             profile_url: "https://www.facebook.com/buttersugoi2.0",)

      url_parser_should_work("https://www.facebook.com/sinyu.tang.9", profile_url: "https://www.facebook.com/sinyu.tang.9")
      url_parser_should_work("https://www.facebook.com/sinyu.tang.9/about", profile_url: "https://www.facebook.com/sinyu.tang.9")
      url_parser_should_work("https://www.fb.com/sinyu.tang.9", profile_url: "https://www.facebook.com/sinyu.tang.9")
    end
  end
end
