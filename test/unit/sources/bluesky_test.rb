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

    context "A post url with DID as user id" do
      strategy_should_work(
        "https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g",
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

    context "A stale access token should automatically refresh" do
      setup do
        # XXX valid expired token, since random string gives HTTP 500 instead
        Cache.put("bluesky-access-token", "eyJhbGciOiJFUzI1NksifQ.eyJzY29wZSI6ImNvbS5hdHByb3RvLmFjY2VzcyIsInN1YiI6ImRpZDpwbGM6bnN3YWk1Z3Z3emE2eGhrdW9lcWNzbmw1IiwiaWF0IjoxNzA3NDkyNjQyLCJleHAiOjE3MDc0OTk4NDIsImF1ZCI6ImRpZDp3ZWI6aHlkbnVtLnVzLXdlc3QuaG9zdC5ic2t5Lm5ldHdvcmsifQ.IP6owPbBT3HZAkTKMynjv5dyVDBG4C9l8kp7cwy5UYDgsXbQ4SeF39pRraDeN_TAocBhShSG22fSMJp2CCBofg")
      end

      strategy_should_work(
        "https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"],
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
