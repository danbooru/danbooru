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
        response = Danbooru::Http.get("https://httpbin.org/absolute-redirect/3")
        assert_equal(200, response.status)
      end

      should "fail if redirected too many times" do
        response = Danbooru::Http.get("https://httpbin.org/absolute-redirect/10")
        assert_equal(598, response.status)
      end

      should "fail if the request takes too long to connect" do
        response = Danbooru::Http.timeout(1).get("https://httpbin.org/delay/5")
        assert_equal(599, response.status)
      end

      should "fail if the request takes too long to download" do
        # XXX should return status 599 instead
        assert_raises(HTTP::TimeoutError) do
          response = Danbooru::Http.timeout(1).get("https://httpbin.org/drip?duration=10&numbytes=10").flush
        end
      end

      should "automatically decompress gzipped responses" do
        response = Danbooru::Http.get("https://httpbin.org/gzip")
        assert_equal(200, response.status)
        assert_equal(true, response.parse["gzipped"])
      end

      should "cache requests" do
        response1 = Danbooru::Http.cache(1.minute).get("https://httpbin.org/uuid")
        assert_equal(200, response1.status)

        response2 = Danbooru::Http.cache(1.minute).get("https://httpbin.org/uuid")
        assert_equal(200, response2.status)
        assert_equal(response2.body, response1.body)
      end
    end

    context "#download method" do
      should "download files" do
        response, file = Danbooru::Http.download_media("https://httpbin.org/bytes/1000")

        assert_equal(200, response.status)
        assert_equal(1000, file.size)
      end

      should "follow redirects when downloading files" do
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
