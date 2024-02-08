require 'test_helper'

module Sources
  class BlueskyTest < ActiveSupport::TestCase

    context "A post url" do
      strategy_should_work(
        "https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"],
        media_files: [{ file_size: 398747 }],
        profile_url: "https://bsky.app/profile/ixy.bsky.social",
        profile_urls: [
          "https://bsky.app/profile/ixy.bsky.social",
          "https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w",
        ],
        page_url: "https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g",
        artist_name: "Ixy(いくしー)",
        tag_name: "ixy",
        tags: [],
        dtext_artist_commentary_desc: "らき☆すた原作２０周年おめでとうございます",
      )
    end

    context "A 'https://cdn.bsky.app/img' url" do
      strategy_should_work(
        "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:3jogsxcisdcdzwjobhxbav2w/bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4@jpeg",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"],
        media_files: [{ file_size: 398747 }],
        profile_urls: ["https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w"],
      )
    end
  
    should "Parse Bluesky URLs correctly" do
      assert(Source::URL.image_url?("https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:3jogsxcisdcdzwjobhxbav2w/bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4@jpeg"))
      assert(Source::URL.image_url?("https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"))
      assert(Source::URL.image_url?("https://morel.us-east.host.bsky.network/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"))

      assert(Source::URL.profile_url?("https://bsky.app/profile/ixy.bsky.social"))
      assert(Source::URL.profile_url?("https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w"))

      assert(Source::URL.page_url?("https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g"))
      assert(Source::URL.page_url?("https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g"))
    end
  end
end
