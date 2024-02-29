require 'test_helper'

class SourceURLTest < ActiveSupport::TestCase
  context "Source::URL" do
    context "parse" do
      should "work for invalid URLs" do
        assert_nil(Source::URL.parse("https://.auone-net.jp/~hakueki/"))
        assert_nil(Source::URL.parse("https://.example.com"))
        assert_nil(Source::URL.parse("https://"))
        assert_nil(Source::URL.parse("https://./"))
        assert_nil(Source::URL.parse("https://!!!.com"))
        # assert_nil(Source::URL.parse("https://foo@gmail.com"))
      end

      should "work for valid URLs" do
        assert_not_nil(Source::URL.parse("https://foo.com."))
        assert_not_nil(Source::URL.parse("https://user:pass@foo.com:80"))
        assert_not_nil(Source::URL.parse("https://localhost"))
      end

      should "normalize URLs" do
        assert_equal("https://example.com/foo%20%09%0B%0C%0D%0Abar", Source::URL.parse("https://example.com/foo \t\v\f\r\nbar").to_normalized_s)
        assert_equal("https://example.com", Source::URL.parse("https://EXAMPLE.COM").to_normalized_s)
      end

      should "parse URLs containing invalid UTF-8" do
        assert_equal("/20140924_45/dnflgmldus_1411489948549jC2ma_PNG/%BD%C3%C1%EE%C7%C3%B7%B9%BE%EE.png", Source::URL.parse("https://cafeptthumb-phinf.pstatic.net/20140924_45/dnflgmldus_1411489948549jC2ma_PNG/%BD%C3%C1%EE%C7%C3%B7%B9%BE%EE.png?type=w1600")&.path)
      end
    end
  end
end
