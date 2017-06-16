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
  end
end
