require "test_helper"

module Source::Tests::URL
  class RedgifsUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://thumbs44.redgifs.com/ThunderousVerifiableScoter-mobile.jpg?expires=1715806200&signature=v2:b774b57f548f8171862b560d007f05b383530e7f167dde99e81b605f158131a5&for=198.54.135&hash=7011125643",
          "https://thumbs44.redgifs.com/ThunderousVerifiableScoter-mobile.mp4?expires=1715806200&signature=v2:41ad91e3b6fa4837191697da448ff9fa0d5386950660da2913faa00c4b029191&for=198.54.135&hash=7011125643",
          "https://thumbs44.redgifs.com/ThunderousVerifiableScoter.mp4?expires=1715806200&signature=v2:5ade027d51718e4482c586504aeb4269be068d0c306d66895c13b1cd971c87ec&for=198.54.135&hash=7011125643",
          "https://userpic.redgifs.com/9/25/9258da4aee0dfd4abe366f60f2c43ce4.png",
        ],
        page_urls: [
          "https://www.redgifs.com/watch/thunderousverifiablescoter",
          "https://www.redgifs.com/ifr/thunderousverifiablescoter",
          "https://i.redgifs.com/i/diligentfluidbichonfrise.jpg",
          "https://api.redgifs.com/v2/gifs/thunderousverifiablescoter",
        ],
        profile_urls: [
          "https://redgifs.com/users/LazyProcrastinator",
          "https://redgifs.com/users/LazyProcrastinator/collections",
        ],
      )
    end
  end
end
