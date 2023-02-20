require 'test_helper'

module Sources
  class AboutMe < ActiveSupport::TestCase
    context "About.me:" do
      should "Parse About.me URLs correctly" do
        assert(Source::URL.image_url?("https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg"))
        assert(Source::URL.image_url?("https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg"))

        assert(Source::URL.profile_url?("https://about.me/sgr_sk"))
        assert(Source::URL.profile_url?("https://about.me/u.no"))

        assert_equal("https://about.me/sgr_sk", Source::URL.profile_url("https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=cover,w=120,h=120,gravity=auto/https://assets.about.me/background/users/s/g/r/sgr_sk_1369590004_43.jpg"))
        assert_equal("https://about.me/u.no", Source::URL.profile_url("https://about.me/cdn-cgi/image/q=40,dpr=2,f=auto,fit=contain,w=1200,h=1799.9100044997751/https://assets.about.me/background/users/u/dot/n/u.no_1471830904_68.jpg"))
      end
    end
  end
end

