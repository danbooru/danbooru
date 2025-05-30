require "test_helper"

module Source::Tests::URL
  class BlueskyUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:3jogsxcisdcdzwjobhxbav2w/bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4@jpeg",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4",
          "https://morel.us-east.host.bsky.network/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4",
        ],
        page_urls: [
          "https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g",
          "https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g",
        ],
        profile_urls: [
          "https://bsky.app/profile/ixy.bsky.social",
          "https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w",
          "https://ixy.bsky.social",
        ],
      )
    end
  end
end
