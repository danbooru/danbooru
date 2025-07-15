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
        assert_nil(Source::URL.parse("https://[]"))
        assert_nil(Source::URL.parse("https://[]:3000"))
        # assert_nil(Source::URL.parse("https://foo@gmail.com"))
      end

      should "work for valid URLs" do
        assert_not_nil(Source::URL.parse("https://foo.com."))
        assert_not_nil(Source::URL.parse("https://user:pass@foo.com:80"))
        assert_not_nil(Source::URL.parse("https://localhost"))
        assert_not_nil(Source::URL.parse("https://127.0.0.1"))
        assert_not_nil(Source::URL.parse("https://127.0.0.1:3000"))
        assert_not_nil(Source::URL.parse("https://[::1]"))
        assert_not_nil(Source::URL.parse("https://[::1]:3000"))
      end

      should "normalize URLs" do
        assert_equal("https://example.com/foo%20%09%0B%0C%0D%0Abar", Source::URL.parse("https://example.com/foo \t\v\f\r\nbar").to_normalized_s)
        assert_equal("https://example.com", Source::URL.parse("https://EXAMPLE.COM").to_normalized_s)
      end

      should "parse URLs containing invalid UTF-8" do
        assert_equal("/20140924_45/dnflgmldus_1411489948549jC2ma_PNG/%BD%C3%C1%EE%C7%C3%B7%B9%BE%EE.png", Source::URL.parse("https://cafeptthumb-phinf.pstatic.net/20140924_45/dnflgmldus_1411489948549jC2ma_PNG/%BD%C3%C1%EE%C7%C3%B7%B9%BE%EE.png?type=w1600")&.path)
      end
    end

    context "the == operator" do
      should "compare URLs strictly" do
        assert(Source::URL.parse("http://google.com") == Source::URL.parse("http://google.com"))

        assert(Source::URL.parse("http://google.com")   != Danbooru::URL.parse("http://google.com"))
        assert(Danbooru::URL.parse("http://google.com") != Source::URL.parse("http://google.com"))
        assert(Source::URL.parse("http://google.com")   != Addressable::URI.parse("http://google.com"))
        assert(Source::URL.parse("http://google.com")   != URI.parse("http://google.com"))
        assert(Source::URL.parse("http://google.com")   != "http://google.com")

        assert(Source::URL.parse("http://google.com") != Source::URL.parse("https://google.com"))
        assert(Source::URL.parse("http://google.com") != Source::URL.parse("http://GOOGLE.com"))
        assert(Source::URL.parse("http://google.com") != Source::URL.parse("http://google.com/"))
        assert(Source::URL.parse("http://google.com") != Source::URL.parse("http://google.com?"))
        assert(Source::URL.parse("http://google.com") != Source::URL.parse("http://google.com#"))
        assert(Source::URL.parse("http://google.com") != Source::URL.parse("http://user:pass@google.com#"))
      end
    end

    context "the === operator" do
      should "compare URLs loosely" do
        assert(Source::URL.parse("http://google.com") === Source::URL.parse("http://google.com"))

        assert(Source::URL.parse("http://google.com")   === Danbooru::URL.parse("http://google.com"))
        assert(Danbooru::URL.parse("http://google.com") === Source::URL.parse("http://google.com"))
        assert(Source::URL.parse("http://google.com")   === Addressable::URI.parse("http://google.com"))
        assert(Source::URL.parse("http://google.com")   === URI.parse("http://google.com"))
        assert(Source::URL.parse("http://google.com")   === "http://google.com")

        assert(Source::URL.parse("http://google.com") === Source::URL.parse("http://GOOGLE.com"))
        assert(Source::URL.parse("http://google.com") === Source::URL.parse("http://google.com/"))

        assert_not(Source::URL.parse("http://google.com") === Source::URL.parse("https://google.com"))
        assert_not(Source::URL.parse("http://google.com") === Source::URL.parse("http://google.com?"))
        assert_not(Source::URL.parse("http://google.com") === Source::URL.parse("http://google.com#"))
        assert_not(Source::URL.parse("http://google.com") === Source::URL.parse("http://user:pass@google.com#"))
      end
    end

    context "the #with method" do
      should "work" do
        assert_equal("http://google.com/image.jpg?foo=baz", Source::URL.parse("http://google.com/image.jpg?foo=bar").with_params(foo: "baz").to_s)
        assert_equal("http://google.com/image.jpg?foo=", Source::URL.parse("http://google.com/image.jpg?foo=bar").with_params(foo: "").to_s)
        assert_equal("http://google.com/image.jpg", Source::URL.parse("http://google.com/image.jpg?foo=bar").with_params(foo: nil).to_s)

        assert_equal("https://example.com/image.jpg?foo=bar", Source::URL.parse("http://google.com/image.jpg?foo=bar").with(site: "https://example.com").to_s)
        assert_equal("http://google.com/image.png?foo=bar", Source::URL.parse("http://google.com/image.jpg?foo=bar").with(file_ext: "png").to_s)
        assert_equal("http://google.com/test.jpg?foo=bar", Source::URL.parse("http://google.com/image.jpg?foo=bar").with(filename: "test").to_s)
        assert_equal("http://google.com/test.png?foo=bar", Source::URL.parse("http://google.com/image.jpg?foo=bar").with(basename: "test.png").to_s)
      end
    end

    context "the #escape method" do
      should "work" do
        assert_equal("fate%2Fstay_night", Source::URL.escape("fate/stay_night"))
        assert_equal("大丈夫%3Fおっぱい揉む%3F", Source::URL.escape("大丈夫?おっぱい揉む?"))
        assert_equal("", Source::URL.escape(nil))
      end
    end
  end
end
