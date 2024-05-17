require 'test_helper'

module Sources
  class BlueskyTest < ActiveSupport::TestCase
    context "A post url with 'app.bsky.embed.images.view' embed" do
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
        display_name: "Ixy(いくしー)",
        username: "ixy",
        tags: [],
        dtext_artist_commentary_desc: "らき☆すた原作２０周年おめでとうございます",
      )
    end

    context "A post url with 'app.bsky.embed.recordWithMedia.view' embed" do
      strategy_should_work(
        "https://bsky.app/profile/yourbaguette.bsky.social/post/3kjarhifsmg26",
        image_urls: [
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreidh7ammduxu7lvwohdfnh6wf2p7f7ty2jh76qe2yysk4vkc3syhbe",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreifh7gbjj5kmrmzmkofedglkltty2bhmukxkez3nuz6q45yypjv5tm",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreic52a6ogfui2kqhhu4jb7nixw3pg45bpmfukbjf6ssunxs57ievmq",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreidzr5uo4mlxxssdluiyhvvbi7k4aner7teuuvex5t6ock3h2byxrm",
        ],
        media_files: [
          { file_size: 773999 },
          { file_size: 953927 },
          { file_size: 829658 },
          { file_size: 831440 },
        ],
        profile_url: "https://bsky.app/profile/yourbaguette.bsky.social",
        profile_urls: [
          "https://bsky.app/profile/yourbaguette.bsky.social",
          "https://bsky.app/profile/did:plc:ekm5wgpt6xhazl7xaipt5ewy",
        ],
        page_url: "https://bsky.app/profile/did:plc:ekm5wgpt6xhazl7xaipt5ewy/post/3kjarhifsmg26",
        display_name: "Baguette",
        username: "yourbaguette",
        tags: ["Art", "FanArt", "Digimon", "SteinsGate", "Omori", "FFXIV"],
        dtext_artist_commentary_desc: "Thanks for the opportunity Bison ! \n\nI'm Baguette, and I mostly draw fanarts of whatever obsession I have ! I will move in Sweden in a week, work on my art and aim to open a little shop this year while working part time ! \n\n#Art #FanArt #Digimon #SteinsGate #Omori #FFXIV",
      )
    end

    context "A post url with 'app.bsky.embed.images.view' - 'images' - 'image' - 'cid' embed" do
      strategy_should_work(
        "https://bsky.app/profile/go-guiltism.bsky.social/post/3klgth6lilt2l",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:owc2r2dsewj3hk73rtd746zh&cid=bafkreieuhplc7fpbvi3suvacaf2dqxzvuu4hgl5o6eifqb76tf3uopldmi"],
        media_files: [{ file_size: 162135 }],
        profile_url: "https://bsky.app/profile/go-guiltism.bsky.social",
        profile_urls: [
          "https://bsky.app/profile/go-guiltism.bsky.social",
          "https://bsky.app/profile/did:plc:owc2r2dsewj3hk73rtd746zh",
        ],
        page_url: "https://bsky.app/profile/did:plc:owc2r2dsewj3hk73rtd746zh/post/3klgth6lilt2l",
        display_name: "Hi-GO!",
        username: "go-guiltism",
        tags: [],
        dtext_artist_commentary_desc: "Copy-X FullArmed 2",
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
        display_name: "Ixy(いくしー)",
        username: "ixy",
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
      assert(Source::URL.profile_url?("https://ixy.bsky.social"))

      assert(Source::URL.page_url?("https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g"))
      assert(Source::URL.page_url?("https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g"))
    end
  end
end
