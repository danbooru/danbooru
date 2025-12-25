require "test_helper"

module Source::Tests::URL
  class GelbooruUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg",
          "http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png",
          "https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg",
          "https://us.rule34.xxx//images/1802/0adc8fa0604dc445b4b47e6f4c436a08.jpeg?1949807",
        ],
        page_urls: [
          "https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e",
          "https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531",
          "https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c",
          "https://rule34.xxx/index.php?page=post&s=view&id=1949807",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg",
                             page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e",)
      url_parser_should_work("http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png",
                             page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531",)
      url_parser_should_work("https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg",
                             page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c",)

      url_parser_should_work("https://us.rule34.xxx//images/1802/0adc8fa0604dc445b4b47e6f4c436a08.jpeg?1949807",
                             page_url: "https://rule34.xxx/index.php?page=post&s=view&id=1949807",)
    end
  end
end
