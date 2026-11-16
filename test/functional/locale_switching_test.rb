require "test_helper"

class LocaleSwitchingTest < ActionDispatch::IntegrationTest
  context "The locale switcher" do
    should "render English by default" do
      get root_path

      assert_response 200
      assert_match(/<html lang="en">/, response.body)
      assert_match(/Posts/, response.body)
    end

    should "render Chinese when ?locale=zh-CN is given" do
      get root_path, params: { locale: "zh-CN" }

      assert_response 200
      assert_match(/<html lang="zh-CN">/, response.body)
      assert_match(/作品/, response.body)
    end

    should "remember the chosen locale in a cookie" do
      get root_path, params: { locale: "zh-CN" }
      get root_path

      assert_match(/<html lang="zh-CN">/, response.body)
    end

    should "honor the Accept-Language header" do
      get root_path, env: { "HTTP_ACCEPT_LANGUAGE" => "zh-CN,zh;q=0.9" }

      assert_match(/<html lang="zh-CN">/, response.body)
    end

    should "fall back to English for an unknown locale" do
      get root_path, params: { locale: "xx" }

      assert_match(/<html lang="en">/, response.body)
    end

    should "tell public caches that the response depends on language" do
      get root_path

      assert_includes response.headers["Vary"].to_s, "Accept-Language"
      assert_includes response.headers["Vary"].to_s, "Cookie"
    end

    should "not reflect reserved url_for options in the switcher links" do
      get root_path, params: { protocol: "javascript", host: "alert(1)", port: "1337" }

      assert_response 200
      hrefs = css_select("#locale-switcher-nav a[href]").pluck("href")
      assert_equal 2, hrefs.size
      assert_empty(hrefs.grep(/alert|1337/), "the switcher reflected reserved url_for options into a link")
      assert(hrefs.any? { |href| href.include?("locale=zh-CN") })
    end
  end
end
