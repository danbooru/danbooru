require "test_helper"

module Sources
  class FacebookTest < ActiveSupport::TestCase
    context "Facebook:" do
      should "Parse URLs correctly" do
        assert(Source::URL.image_url?("https://scontent-sin1-1.xx.fbcdn.net/hphotos-xtp1/t31.0-8/11254493_576443445841777_7716273903390212288_o.jpg"))
        assert(Source::URL.image_url?("https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg"))
        assert(Source::URL.page_url?("https://www.facebook.com/photo?fbid=1362164640578443"))
        assert(Source::URL.page_url?("https://www.facebook.com/reel/373226486954887/"))
        assert(Source::URL.page_url?("https://www.facebook.com/100045011383201/posts/845746695605598"))
        assert(Source::URL.profile_url?("https://www.facebook.com/profile.php?id=100007366415557&name=xhp_nt__fblite__profile__tab_bar"))
        assert(Source::URL.profile_url?("https://www.facebook.com/sinyu.tang.9"))

        assert_equal("https://www.facebook.com/photo?fbid=576443445841777", Source::URL.page_url("https://scontent-sin1-1.xx.fbcdn.net/hphotos-xtp1/t31.0-8/11254493_576443445841777_7716273903390212288_o.jpg"))
        assert_equal("https://www.facebook.com/photo?fbid=623015164516858", Source::URL.page_url("https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg"))

        assert_equal("https://www.facebook.com/profile.php?id=100007366415557", Source::URL.profile_url("https://www.facebook.com/profile.php?id=100007366415557&name=xhp_nt__fblite__profile__tab_bar"))
        assert_equal("https://www.facebook.com/profile.php?id=100007366415557", Source::URL.profile_url("https://www.facebook.com/profile/100007366415557"))
        assert_equal("https://www.facebook.com/profile.php?id=61550637164305", Source::URL.profile_url("https://www.facebook.com/p/Chocotoffys-61550637164305/"))
        assert_equal("https://www.facebook.com/profile.php?id=61565499492869", Source::URL.profile_url("https://www.facebook.com/people/Abandir/61565499492869/"))
        assert_equal("https://www.facebook.com/buttersugoi2.0", Source::URL.profile_url("https://www.facebook.com/buttersugoi2.0/posts/pfbid052HT8bQg1QzN4V8s7wouB6DEEnP9DudwpuGPtoqgUAg9WC7Ug2Z94gYXtB2S37oBl"))
        assert_equal("https://www.facebook.com/sinyu.tang.9", Source::URL.profile_url("https://www.facebook.com/sinyu.tang.9"))
        assert_equal("https://www.facebook.com/sinyu.tang.9", Source::URL.profile_url("https://www.facebook.com/sinyu.tang.9/about"))
        assert_equal("https://www.facebook.com/sinyu.tang.9", Source::URL.profile_url("https://www.fb.com/sinyu.tang.9"))

        assert_nil(Source::URL.bad_source?("https://www.facebook.com/groups/AnatomyandAction/permalink/2647641035431143/?mibextid=Nif5oz"))
      end
    end
  end
end
