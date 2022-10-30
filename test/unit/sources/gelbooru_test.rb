require "test_helper"

module Sources
  class GelbooruTest < ActiveSupport::TestCase
    context "A Gelbooru direct image url without a referer" do
      strategy_should_work(
        "https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬bot",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow bangs black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_headwear witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        download_size: 480_621,
      )
    end

    context "A Gelbooru direct image url with a referer" do
      strategy_should_work(
        "https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg",
        referer: "https://gelbooru.com/index.php?page=post&s=view&id=7798121",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬bot",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow bangs black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_headwear witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        download_size: 480_621,
      )
    end

    context "A Gelbooru sample image url" do
      strategy_should_work(
        "https://img3.gelbooru.com/samples/04/f2/sample_04f2767c64593c3030ce74ecc2528704.jpg",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬bot",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow bangs black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_headwear witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        download_size: 480_621,
      )
    end

    context "A Gelbooru page url" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=view&id=7798121",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬bot",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow bangs black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_headwear witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        download_size: 480_621,
      )
    end

    context "A Gelbooru md5 page url" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=list&md5=04f2767c64593c3030ce74ecc2528704",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬bot",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow bangs black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_headwear witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        download_size: 480_621,
      )
    end

    should "normalize gelbooru links" do
      source1 = "https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg"
      source2 = "http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png"
      source3 = "https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg"

      assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e", Source::URL.page_url(source1))
      assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531", Source::URL.page_url(source2))
      assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c", Source::URL.page_url(source3))
    end
  end
end
