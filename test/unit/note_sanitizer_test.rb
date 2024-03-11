# frozen_string_literal: true

require 'test_helper'

class NoteSanitizerTest < ActiveSupport::TestCase
  context "Sanitizing a note" do
    should "strip unsafe tags" do
      body = '<p>test</p> <script>alert("owned")</script>'
      assert_equal('<p>test</p> ', NoteSanitizer.sanitize(body))
    end

    should "strip unsafe css" do
      body = '<p style="background-image: url(http://www.google.com);">test</p>'
      assert_equal("<p>test</p>", NoteSanitizer.sanitize(body))
    end

    should "allow style attributes on every tag" do
      body = '<p style="font-size: 1em;">test</p>'
      assert_equal('<p style="font-size: 1em;">test</p>', NoteSanitizer.sanitize(body))
    end

    should "not strip allowed style properties" do
      assert_equal('<p style="position: absolute;">test</p>', NoteSanitizer.sanitize('<p style="position: absolute;">test</p>'))
      assert_equal('<p style="position: Absolute;">test</p>', NoteSanitizer.sanitize('<p style="position: Absolute;">test</p>'))
      assert_equal('<p style="position: relative;">test</p>', NoteSanitizer.sanitize('<p style="position: relative;">test</p>'))
      assert_equal('<p style="position: relative;">test</p>', NoteSanitizer.sanitize('<p style="  position: relative;  ">test</p>'))
      assert_equal('<p style="color: red;position: relative;color: green;">test</p>', NoteSanitizer.sanitize('<p style="  color: red;; ;; position: relative;; ;;  color: green;; ;;">test</p>'))
    end

    should "strip disallowed style properties" do
      assert_equal('<p>test</p>', NoteSanitizer.sanitize('<p style="position: fixed;">test</p>'))
      assert_equal('<p>test</p>', NoteSanitizer.sanitize('<p style="position: sticky;">test</p>'))
      assert_equal('<p>test</p>', NoteSanitizer.sanitize('<p style="display: none;">test</p>'))

      assert_equal('<p style="color: red;">test</p>', NoteSanitizer.sanitize('<p style="position: fixed; color: red;">test</p>'))
      assert_equal('<p style="color: red;">test</p>', NoteSanitizer.sanitize('<p style="position: fixed; ; ; ; color: red;">test</p>'))

      assert_equal('<p>test</p>', NoteSanitizer.sanitize('<p style=";">test</p>'))
    end

    should "mark links as nofollow" do
      body = '<a href="http://www.google.com">google</a>'
      assert_equal('<a href="http://www.google.com" rel="external noreferrer nofollow">google</a>', NoteSanitizer.sanitize(body))
    end

    should "rewrite absolute links to relative links" do
      Danbooru.config.stubs(:canonical_url).returns("http://sonohara.donmai.us")

      body = '<a href="http://sonohara.donmai.us/posts?tags=touhou#dtext-intro">touhou</a>'
      assert_equal('<a href="/posts?tags=touhou#dtext-intro" rel="external noreferrer nofollow">touhou</a>', NoteSanitizer.sanitize(body))
    end

    should "not fail when rewriting bad links" do
      body = %{<a href ="\nhttp!://www.google.com:12x3">google</a>}
      assert_equal(%{<a rel="external noreferrer nofollow">google</a>}, NoteSanitizer.sanitize(body))
    end

    should "escape '<' characters properly" do
      assert_equal("foo &lt; bar", NoteSanitizer.sanitize("foo < bar"))
      assert_equal("foo &lt;- bar", NoteSanitizer.sanitize("foo <- bar"))
      assert_equal("foo &lt;3 bar", NoteSanitizer.sanitize("foo <3 bar"))
      assert_equal("foo &lt;: bar", NoteSanitizer.sanitize("foo <: bar"))
      assert_equal("foo &lt;&gt; bar", NoteSanitizer.sanitize("foo <> bar"))
      assert_equal("foo &lt;", NoteSanitizer.sanitize("foo <"))

      assert_equal("foo ", NoteSanitizer.sanitize("foo <x bar"))
      assert_equal("foo ", NoteSanitizer.sanitize("foo <? bar"))
      assert_equal("foo ", NoteSanitizer.sanitize("foo <! bar"))
      assert_equal("foo ", NoteSanitizer.sanitize("foo </ bar"))
    end

    should "not fail on a frozen string" do
      assert_equal("", NoteSanitizer.sanitize("".freeze))
    end

    should "not fail on nil" do
      assert_equal("", NoteSanitizer.sanitize(nil))
    end
  end
end
