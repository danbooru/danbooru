require 'test_helper'

class DanbooruHttpTest < ActiveSupport::TestCase
  context "Danbooru::Http" do
    context "#get method" do
      should "work for all basic methods" do
        %i[get put post delete].each do |method|
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
        response = Danbooru::Http.timeout(1).get("https://httpbin.org/drip?duration=5&numbytes=5")
        assert_equal(599, response.status)
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
  end
end
