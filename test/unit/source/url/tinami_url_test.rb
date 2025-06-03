require "test_helper"

module Source::Tests::URL
  class TinamiUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://img.tinami.com/illust/img/287/497c8a9dc60e6.jpg",
          "https://img.tinami.com/comic/naomao/naomao_001_01.jpg",
          "https://www.tinami.com/view/tweet/card/461459",
        ],
        page_urls: [
          "https://www.tinami.com/view/461459",
        ],
        profile_urls: [
          "http://www.tinami.com/creator/profile/1624",
          "https://www.tinami.com/search/list?prof_id=1624",
        ],
      )

      should_not_find_false_positives(
        profile_urls: [
          "http://www.tinami.com/profile/1182",
        ],
      )
    end
  end
end
