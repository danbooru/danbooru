require 'test_helper'

class DanbooruHttpTest < ActiveSupport::TestCase
  context "Danbooru::Http" do
    context "#get method" do
      should "work for all basic methods" do
        %i[get head put post delete].each do |method|
          response = Danbooru::Http.send(method, "https://httpbin.org/status/200")
          assert_equal(200, response.status)
        end
      end

      should "follow redirects" do
        skip "Skipping test (https://github.com/postmanlabs/httpbin/issues/617)"
        response = Danbooru::Http.get("https://httpbin.org/absolute-redirect/3")
        assert_equal(200, response.status)
      end

      should "fail if redirected too many times" do
        skip "Skipping test (https://github.com/postmanlabs/httpbin/issues/617)"
        response = Danbooru::Http.get("https://httpbin.org/absolute-redirect/10")
        assert_equal(596, response.status)
      end

      should "fail if the request takes too long to connect" do
        response = Danbooru::Http.timeout(1).get("https://httpbin.org/delay/5")
        assert_equal(597, response.status)
      end

      should "fail if the request takes too long to download" do
        # XXX should return status 597 instead
        assert_raises(HTTP::TimeoutError) do
          response = Danbooru::Http.timeout(1).get("https://httpbin.org/drip?duration=10&numbytes=10").flush
        end
      end

      should "return a 5xx error if the domain can't be resolved" do
        response = Danbooru::Http.get("http://doesnotexist.donmai.us")
        assert_equal(598, response.status)
      end

      should "return a 5xx error if the SSL certificate is expired" do
        response = Danbooru::Http.get("https://expired.badssl.com")
        assert_equal(590, response.status)
      end

      should "automatically decompress gzipped responses" do
        response = Danbooru::Http.get("https://httpbin.org/gzip")
        assert_equal(200, response.status)
        assert_equal(true, response.parse["gzipped"])
      end

      should "automatically parse html responses" do
        response = Danbooru::Http.get("https://httpbin.org/html")
        assert_equal(200, response.status)
        assert_instance_of(Nokogiri::HTML5::Document, response.parse)
        assert_equal("Herman Melville - Moby-Dick", response.parse.css("h1").text)
      end

      should "automatically parse xml responses" do
        response = Danbooru::Http.get("https://httpbin.org/xml")
        assert_equal(200, response.status)
        assert_equal(true, response.parse[:slideshow].present?)
      end

      should "track cookies between requests" do
        http = Danbooru::Http.use(:session)

        resp1 = http.get("https://httpbin.org/cookies/set/abc/1")
        resp2 = http.get("https://httpbin.org/cookies/set/def/2")
        resp3 = http.get("https://httpbin.org/cookies")
        assert_equal({ abc: "1", def: "2" }, resp3.parse["cookies"].symbolize_keys)

        resp4 = http.cookies(def: 3, ghi: 4).get("https://httpbin.org/cookies")
        assert_equal({ abc: "1", def: "3", ghi: "4" }, resp4.parse["cookies"].symbolize_keys)
      end
    end

    context "cache feature" do
      should "cache multiple requests to the same url" do
        http = Danbooru::Http.cache(1.hour)

        response1 = http.get("https://httpbin.org/uuid")
        assert_equal(200, response1.status)

        response2 = http.get("https://httpbin.org/uuid")
        assert_equal(200, response2.status)
        assert_equal(response2.to_s, response1.to_s)
      end

      should "cache cookies correctly" do
        http = Danbooru::Http.cache(1.hour)

        resp1 = http.get("https://httpbin.org/cookies")
        resp2 = http.get("https://httpbin.org/cookies/set/abc/1")
        resp3 = http.get("https://httpbin.org/cookies/set/def/2")
        resp4 = http.get("https://httpbin.org/cookies")

        assert_equal(200, resp1.status)
        assert_equal(200, resp2.status)
        assert_equal(200, resp3.status)
        assert_equal(200, resp4.status)

        assert_equal({}, resp1.parse["cookies"].symbolize_keys)
        assert_equal({ abc: "1" }, resp2.parse["cookies"].symbolize_keys)
        assert_equal({ abc: "1", def: "2" }, resp3.parse["cookies"].symbolize_keys)
        assert_equal({ abc: "1", def: "2" }, resp4.parse["cookies"].symbolize_keys)
      end
    end

    context "retriable feature" do
      should "retry immediately if no Retry-After header is sent" do
        response_429 = ::HTTP::Response.new(status: 429, version: "1.1", body: "")
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "")
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_429, response_200)

        response = Danbooru::Http.use(:retriable).get("https://httpbin.org/status/429")
        assert_equal(200, response.status)
      end

      should "retry if the Retry-After header is an integer" do
        response_503 = ::HTTP::Response.new(status: 503, version: "1.1", headers: { "Retry-After": "1" }, body: "")
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "")
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_503, response_200)

        response = Danbooru::Http.use(:retriable).get("https://httpbin.org/status/503")
        assert_equal(200, response.status)
      end

      should "retry if the Retry-After header is a date" do
        response_503 = ::HTTP::Response.new(status: 503, version: "1.1", headers: { "Retry-After": 2.seconds.from_now.httpdate }, body: "")
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "")
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_503, response_200)

        response = Danbooru::Http.use(:retriable).get("https://httpbin.org/status/503")
        assert_equal(200, response.status)
      end
    end

    context "spoof referrer feature" do
      should "spoof the referer" do
        response = Danbooru::Http.use(:spoof_referrer).get("https://httpbin.org/anything")

        assert_equal(200, response.status)
        assert_equal("https://httpbin.org", response.parse.dig("headers", "Referer"))
      end
    end

    context "unpolish cloudflare feature" do
      should "return the original image for polished images" do
        url = "https://cdnb.artstation.com/p/assets/images/images/025/273/307/4k/atey-ghailan-a-sage-keyart-s-ch-04-outlined-1.jpg?1585246642"
        response = Danbooru::Http.use(:unpolish_cloudflare).get(url)

        assert_equal(200, response.status)
        assert_equal(622_594, response.content_length)
      end
    end

    context "#download method" do
      should "download files" do
        response, file = Danbooru::Http.download_media("https://httpbin.org/bytes/1000")

        assert_equal(200, response.status)
        assert_equal(1000, file.size)
      end

      should "follow redirects when downloading files" do
        skip "Skipping test (https://github.com/postmanlabs/httpbin/issues/617)"
        response, file = Danbooru::Http.download_media("https://httpbin.org/redirect-to?url=https://httpbin.org/bytes/1000")

        assert_equal(200, response.status)
        assert_equal(1000, file.size)
      end

      should "fail if the url points to a private IP" do
        assert_raises(Danbooru::Http::DownloadError) do
          Danbooru::Http.public_only.download_media("https://127.0.0.1.xip.io")
        end
      end

      should "fail if the url redirects to a private IP" do
        assert_raises(Danbooru::Http::DownloadError) do
          Danbooru::Http.public_only.download_media("https://httpbin.org/redirect-to?url=https://127.0.0.1.xip.io")
        end
      end

      should "fail if a download is too large" do
        assert_raises(Danbooru::Http::FileTooLargeError) do
          response, file = Danbooru::Http.max_size(500).download_media("https://httpbin.org/bytes/1000")
        end
      end

      should "fail if a streaming download is too large" do
        assert_raises(Danbooru::Http::FileTooLargeError) do
          response, file = Danbooru::Http.max_size(500).download_media("https://httpbin.org/stream-bytes/1000")
        end
      end
    end
  end
end
