require 'test_helper'

class NoteSanitizerTest < ActiveSupport::TestCase
  context "Sanitizing a note" do
    should "strip unsafe tags" do
      body = '<p>test</p> <script>alert("owned")</script>'
      assert_equal('<p>test</p> alert("owned")', NoteSanitizer.sanitize(body))
    end

    should "strip unsafe css" do
      body = '<p style="background-image: url(http://www.google.com);">test</p>'
      assert_equal("<p>test</p>", NoteSanitizer.sanitize(body))
    end

    should "allow style attributes on every tag" do
      body = '<p style="font-size: 1em;">test</p>'
      assert_equal('<p style="font-size: 1em;">test</p>', NoteSanitizer.sanitize(body))
    end

    should "mark links as nofollow" do
      body = '<a href="http://www.google.com">google</a>'
      assert_equal('<a href="http://www.google.com" rel="nofollow">google</a>', NoteSanitizer.sanitize(body))
    end

    should "rewrite absolute links to relative links" do
      Danbooru.config.stubs(:hostnames).returns(%w[danbooru.donmai.us sonohara.donmai.us hijiribe.donmai.us])

      body = '<a href="http://sonohara.donmai.us/posts?tags=touhou#dtext-intro">touhou</a>'
      assert_equal('<a href="/posts?tags=touhou#dtext-intro" rel="nofollow">touhou</a>', NoteSanitizer.sanitize(body))
    end
  end
end
