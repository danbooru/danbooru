require 'test_helper'

module Sources
  class E621Test < ActiveSupport::TestCase
    should "Parse e621 URLs correctly" do
      assert(Source::URL.image_url?("https://static1.e621.net/data/sample/ae/ae/aeaed0dfba6468ec992c6e5cc46763c1_720p.mp4"))
      assert(Source::URL.image_url?("https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg"))
      assert(Source::URL.image_url?("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png"))

      assert_equal("https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a", Source::URL.page_url("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png"))

      assert(Source::URL.page_url?("https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a"))
      assert(Source::URL.page_url?("https://e621.net/posts/3728701"))
      assert(Source::URL.page_url?("https://e926.net/posts/3728701"))

      assert(Source::URL.profile_url?("https://e621.net/users/205980"))
    end
  end
end
