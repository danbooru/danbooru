require 'test_helper'

class DanbooruHttpTest < ActiveSupport::TestCase
  def httpbin_url(path = "")
    "https://nghttp2.org/httpbin/#{path}"
  end

  context "Danbooru::Http" do
    context "#get method" do
      should "work for all basic methods" do
        %i[get head put post delete].each do |method|
          response = Danbooru::Http.send(method, httpbin_url("status/200"))
          assert_equal(200, response.status)
        end
      end

      should "follow redirects" do
        response = Danbooru::Http.get(httpbin_url("absolute-redirect/3"))
        assert_equal(200, response.status)
      end

      should "fail if redirected too many times" do
        response = Danbooru::Http.get(httpbin_url("absolute-redirect/10"))
        assert_equal(596, response.status)
        assert_equal("", response.body.to_s)
      end

      should "fail if the request takes too long to connect" do
        response = Danbooru::Http.timeout(1).get(httpbin_url("delay/5"))
        assert_equal(597, response.status)
        assert_equal("", response.body.to_s)
      end

      should "fail if the request takes too long to download" do
        # XXX should return status 597 instead
        assert_raises(HTTP::TimeoutError) do
          response = Danbooru::Http.timeout(1).get(httpbin_url("drip?duration=10&numbytes=10")).flush
        end
      end

      should "return a 5xx error if the domain can't be resolved" do
        response = Danbooru::Http.get("http://doesnotexist.donmai.us")
        assert_equal(598, response.status)
        assert_equal("", response.body.to_s)
      end

      should "return a 5xx error if the SSL certificate is expired" do
        response = Danbooru::Http.get("https://expired.badssl.com")
        assert_equal(590, response.status)
        assert_equal("", response.body.to_s)
      end

      should "automatically decompress gzipped responses" do
        response = Danbooru::Http.get(httpbin_url("gzip"))
        assert_equal(200, response.status)
        assert_equal(true, response.parse["gzipped"])
      end

      should "automatically parse html responses" do
        response = Danbooru::Http.get(httpbin_url("html"))
        assert_equal(200, response.status)
        assert_instance_of(Nokogiri::HTML5::Document, response.parse)
        assert_equal("Herman Melville - Moby-Dick", response.parse.css("h1").text)
      end

      should "automatically parse xml responses" do
        response = Danbooru::Http.get(httpbin_url("xml"))
        assert_equal(200, response.status)
        assert_equal(true, response.parse[:slideshow].present?)
      end

      should "track cookies between requests" do
        http = Danbooru::Http.use(:session)

        resp1 = http.get(httpbin_url("cookies/set/abc/1"))
        resp2 = http.get(httpbin_url("cookies/set/def/2"))
        resp3 = http.get(httpbin_url("cookies"))
        assert_equal({ abc: "1", def: "2" }, resp3.parse["cookies"].symbolize_keys)

        resp4 = http.cookies(def: 3, ghi: 4).get(httpbin_url("cookies"))
        assert_equal({ abc: "1", def: "3", ghi: "4" }, resp4.parse["cookies"].symbolize_keys)
      end

      should "work for a URL containing special characters" do
        resp = Danbooru::Http.get(httpbin_url("anything/foo 😃`~!@$%^&*()_-+={}[]|\\:;\"'<>,./?bar=baz 😃`~!@$^&*()_-+={}[]|\\:;\"'<>,./&blah😃#hash"))

        assert_equal(200, resp.status)
        assert_equal(httpbin_url("anything/foo%20%F0%9F%98%83%60~!@$%25%5E&*()_-+=%7B%7D%5B%5D%7C%5C:;%22'%3C%3E,./?bar=baz%20%F0%9F%98%83`~!@$^&*()_-+={}[]|\\:;\"'<>,./&blah%F0%9F%98%83#hash"), resp.request.uri.to_s)
        assert_equal(httpbin_url("anything/foo%20😃%60~%21%40%24%25%5E%26%2A%28%29_-%2B%3D%7B%7D%5B%5D%7C%5C:%3B%22%27%3C%3E%2C./?bar=baz%20😃%60~!%40$%5E&*()_-+=%7B%7D%5B%5D%7C%5C:%3B%22'%3C%3E,.%2F&blah😃"), resp.parse["url"])
      end

      should "work for a URL containing percent-encoded characters" do
        resp = Danbooru::Http.get(httpbin_url("anything/foo%20bar"))

        assert_equal(200, resp.status)
        assert_equal(httpbin_url("anything/foo%20bar"), resp.request.uri.to_s)
        assert_equal(httpbin_url("anything/foo%20bar"), resp.parse["url"])
      end

      should "work for a URL containing Unicode characters" do
        resp = Danbooru::Http.get(httpbin_url("anything/東方"))
        assert_equal(200, resp.status)
        assert_equal(httpbin_url("anything/東方"), resp.parse["url"])
      end

      should "not normalize Unicode characters to NFC form" do
        resp = Danbooru::Http.head(httpbin_url("anything/\u30D5\u3099")) # U+30D5 U+3099 = ブ ('KATAKANA LETTER HU', 'COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK')
        assert_equal(httpbin_url("anything/%E3%83%95%E3%82%99"), resp.request.uri.to_s)

        resp = Danbooru::Http.head("https://tuyu-official.jp/wp/wp-content/uploads/2022/09/雨模様［サブスクジャケット］.jpeg")
        assert_equal(200, resp.status)
        assert_equal("%E9%9B%A8%E6%A8%A1%E6%A7%98%EF%BC%BB%E3%82%B5%E3%83%95%E3%82%99%E3%82%B9%E3%82%AF%E3%82%B7%E3%82%99%E3%83%A3%E3%82%B1%E3%83%83%E3%83%88%EF%BC%BD.jpeg", resp.request.uri.path.split("/").last)
      end

      should "work for a Source::URL" do
        resp = Danbooru::Http.get(Source::URL.parse("https://www.google.com"))

        assert_equal(200, resp.status)
      end

      should "work for a Source::URL that returns an error" do
        resp = Danbooru::Http.get(Source::URL.parse("https://www.google.dne"))

        assert_equal(598, resp.status)
      end
    end

    context "#post method" do
      should "follow 302 redirects with a GET" do
        response = Danbooru::Http.get(httpbin_url("redirect-to?url=#{httpbin_url("get")}"))
        assert_equal(200, response.status)
      end

      should "work for POST requests with JSON encoded bodies" do
        response = Danbooru::Http.post(httpbin_url("/post"), json: { foo: "bar" })
        assert_equal(200, response.status)
      end
    end

    context "#redirect_url method" do
      should "follow redirects to the final URL" do
        assert_equal("http://www.google.com/", Danbooru::Http.redirect_url("http://google.com").to_s)
        assert_equal("https://www.google.com/", Danbooru::Http.redirect_url("https://google.com").to_s)

        assert_equal(nil, Danbooru::Http.redirect_url("https://google.dne"))
      end
    end

    context "cache feature" do
      should "cache multiple requests to the same url" do
        http = Danbooru::Http.cache(1.hour)

        response1 = http.get(httpbin_url("uuid"))
        assert_equal(200, response1.status)

        response2 = http.get(httpbin_url("uuid"))
        assert_equal(200, response2.status)
        assert_equal(response2.to_s, response1.to_s)
      end

      should "cache cookies correctly" do
        http = Danbooru::Http.cache(1.hour)

        resp1 = http.get(httpbin_url("cookies"))
        resp2 = http.get(httpbin_url("cookies/set/abc/1"))
        resp3 = http.get(httpbin_url("cookies/set/def/2"))
        resp4 = http.get(httpbin_url("cookies"))

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
      should "not retry if the Retry-After header is sent with a 2xx or 3xx response" do
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", headers: { "Retry-After": "0" }, body: "", request: nil)
        HTTP::Client.any_instance.expects(:perform).times(1).returns(response_200)

        response = Danbooru::Http.use(:retriable).get(httpbin_url("status/200"))
        assert_equal(200, response.status)
      end

      should "retry after the max_delay if the server returns a 429 error with no Retry-After header" do
        response_429 = ::HTTP::Response.new(status: 429, version: "1.1", body: "", request: nil)
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "", request: nil)
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_429, response_200)

        duration = Benchmark.realtime do
          response = Danbooru::Http.use(retriable: { max_delay: 1.second }).get(httpbin_url("status/429"))
          assert_equal(200, response.status)
        end

        assert_includes(1.0..1.1, duration)
      end

      should "retry immediately if the request returns a >=597 error" do
        response_597 = ::HTTP::Response.new(status: 597, version: "1.1", body: "", request: nil)
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "", request: nil)
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_597, response_200)

        response = Danbooru::Http.use(:retriable).get(httpbin_url("status/597"))
        assert_equal(200, response.status)
      end

      should "retry if the Retry-After header is an integer" do
        response_429 = ::HTTP::Response.new(status: 429, version: "1.1", headers: { "Retry-After": "1" }, body: "", request: nil)
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "", request: nil)
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_429, response_200)

        response = Danbooru::Http.use(:retriable).get(httpbin_url("status/429"))
        assert_equal(200, response.status)
      end

      should "retry if the Retry-After header is a date" do
        response_429 = ::HTTP::Response.new(status: 429, version: "1.1", headers: { "Retry-After": 2.seconds.from_now.httpdate }, body: "", request: nil)
        response_200 = ::HTTP::Response.new(status: 200, version: "1.1", body: "", request: nil)
        HTTP::Client.any_instance.expects(:perform).times(2).returns(response_429, response_200)

        response = Danbooru::Http.use(:retriable).get(httpbin_url("status/429"))
        assert_equal(200, response.status)
      end
    end

    context "spoof referrer feature" do
      should "spoof the referer" do
        response = Danbooru::Http.use(:spoof_referrer).get(httpbin_url("anything"))

        assert_equal(200, response.status)
        assert_equal(httpbin_url("anything"), response.parse.dig("headers", "Referer"))
      end
    end

    context "unpolish cloudflare feature" do
      should "return the original image for polished images" do
        skip if ENV["CI"].present?

        url = "https://cdnb.artstation.com/p/assets/images/images/025/273/307/4k/atey-ghailan-a-sage-keyart-s-ch-04-outlined-1.jpg?1585246642"
        response = Danbooru::Http.use(:unpolish_cloudflare).get(url)

        assert_equal(200, response.status.to_i)
        assert_equal(622_784, response.content_length)
      end
    end

    context "public_only feature" do
      should "disallow connections to non-public IPs" do
        response = Danbooru::Http.public_only.get("http://127.0.0.1/foo.txt")

        assert_equal(591, response.status)
      end

      should "not raise an exception if the domain doesnt't exist" do
        response = Danbooru::Http.public_only.get("http://google.dne")

        assert_equal(598, response.status)
      end
    end

    context "#download method" do
      should "download files" do
        response, file = Danbooru::Http.download_media(httpbin_url("bytes/1000"))

        assert_equal(200, response.status)
        assert_equal(1000, file.size)
      end

      should "follow redirects when downloading files" do
        response, file = Danbooru::Http.download_media(httpbin_url("/redirect-to?url=#{httpbin_url("bytes/1000")}"))

        assert_equal(200, response.status)
        assert_equal(1000, file.size)
      end

      should "fail if the url points to a private IP" do
        assert_raises(Danbooru::Http::DownloadError) do
          Danbooru::Http.public_only.download_media("https://127.0.0.1.nip.io")
        end
      end

      should "fail if the url redirects to a private IP" do
        assert_raises(Danbooru::Http::DownloadError) do
          Danbooru::Http.public_only.download_media(httpbin_url("redirect-to?url=https://127.0.0.1.nip.io"))
        end
      end

      should "fail if a download is too large" do
        assert_raises(Danbooru::Http::FileTooLargeError) do
          response, file = Danbooru::Http.max_size(500).download_media(httpbin_url("bytes/1000"))
        end
      end

      should "fail if a streaming download is too large" do
        assert_raises(Danbooru::Http::FileTooLargeError) do
          response, file = Danbooru::Http.max_size(500).download_media(httpbin_url("stream-bytes/1000"))
        end
      end
    end
  end
end
