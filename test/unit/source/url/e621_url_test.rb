require "test_helper"

module Source::Tests::URL
  class E621UrlTest < ActiveSupport::TestCase
    context "E621 URLs" do
      should be_image_url(
        "https://static1.e621.net/data/sample/ae/ae/aeaed0dfba6468ec992c6e5cc46763c1_720p.mp4",
        "https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg",
        "https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png",
      )

      should be_page_url(
        "https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a",
        "https://e621.net/posts/3728701",
        "https://e926.net/posts/3728701",
      )

      should be_profile_url(
        "https://e621.net/users/205980",
      )

      should parse_url("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png").into(
        page_url: "https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a",
      )
    end
  end
end
