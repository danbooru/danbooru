require 'test_helper'

class SourceURLTest < ActiveSupport::TestCase
  context "Source::URL" do
    context "parse" do
      should "work for invalid URLs" do
        assert_nil(Source::URL.parse("https://.auone-net.jp/~hakueki/"))
        assert_nil(Source::URL.parse("https://.example.com"))
        assert_nil(Source::URL.parse("https://"))
      end

      should "work for valid URLs" do
        assert_not_nil(Source::URL.parse("https://foo.com."))
        assert_not_nil(Source::URL.parse("https://user:pass@foo.com:80"))

        assert_not_nil(Source::URL.parse("https://!!!.com")) # XXX invalid
      end

      should "normalize URLs" do
        assert_equal("https://example.com/foo%20%09%0B%0C%0D%0Abar", Source::URL.parse("https://example.com/foo \t\v\f\r\nbar").to_normalized_s)
      end
    end
  end
end
