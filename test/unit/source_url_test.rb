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
    end
  end
end
