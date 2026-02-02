require "test_helper"

module Source::Tests::Extractor
  class BlueskyExtractorTest < ActiveSupport::ExtractorTestCase
    setup do
      skip "Bluesky credentials not configured" unless Source::Extractor::Bluesky.enabled?
    end

    context "A post url with 'app.bsky.embed.images.view' embed" do
      strategy_should_work(
        "https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"],
        media_files: [{ file_size: 398_747 }],
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

    context "A post with 'app.bsky.embed.images.view' embed and alt text" do
      strategy_should_work(
        "https://bsky.app/profile/magicianhero.bsky.social/post/3ljtkgqzwvc2t",
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          renmerry "#東方Project":[https://bsky.app/hashtag/東方Project] "#touhou":[https://bsky.app/hashtag/touhou]

          [quote]
          h6. Image Description

          chibis of renko usami and maribel hearn. in two figures they're separated and in one figure they are both dancing.
          [/quote]
        EOS
      )
    end

    context "A post url with 'app.bsky.embed.recordWithMedia.view' embed and alt text" do
      strategy_should_work(
        "https://bsky.app/profile/yourbaguette.bsky.social/post/3kjarhifsmg26",
        image_urls: [
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreidh7ammduxu7lvwohdfnh6wf2p7f7ty2jh76qe2yysk4vkc3syhbe",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreifh7gbjj5kmrmzmkofedglkltty2bhmukxkez3nuz6q45yypjv5tm",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreic52a6ogfui2kqhhu4jb7nixw3pg45bpmfukbjf6ssunxs57ievmq",
          "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:ekm5wgpt6xhazl7xaipt5ewy&cid=bafkreidzr5uo4mlxxssdluiyhvvbi7k4aner7teuuvex5t6ock3h2byxrm",
        ],
        media_files: [
          { file_size: 773_999 },
          { file_size: 953_927 },
          { file_size: 829_658 },
          { file_size: 831_440 },
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
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Thanks for the opportunity Bison !

          I'm Baguette, and I mostly draw fanarts of whatever obsession I have ! I will move in Sweden in a week, work on my art and aim to open a little shop this year while working part time !

          "#Art":[https://bsky.app/hashtag/Art] "#FanArt":[https://bsky.app/hashtag/FanArt] "#Digimon":[https://bsky.app/hashtag/Digimon] "#SteinsGate":[https://bsky.app/hashtag/SteinsGate] "#Omori":[https://bsky.app/hashtag/Omori] "#FFXIV":[https://bsky.app/hashtag/FFXIV]

          [quote]
          h6. Image Description

          A fanart of Togemon from the digimon universe
          [/quote]

          [quote]
          h6. Image Description

          A Fanart from Basil, from Omori
          [/quote]

          [quote]
          h6. Image Description

          A fanart of two silly lalafells from ffxiv
          [/quote]

          [quote]
          h6. Image Description

          A fanart of Mayushii from Stein's Gate
          [/quote]
        EOS
      )
    end

    context "A post url with 'app.bsky.embed.images.view' - 'images' - 'image' - 'cid' embed" do
      strategy_should_work(
        "https://bsky.app/profile/go-guiltism.bsky.social/post/3klgth6lilt2l",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:owc2r2dsewj3hk73rtd746zh&cid=bafkreieuhplc7fpbvi3suvacaf2dqxzvuu4hgl5o6eifqb76tf3uopldmi"],
        media_files: [{ file_size: 162_135 }],
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

    context "A post with a video" do
      strategy_should_work(
        "https://bsky.app/profile/tuyoki.bsky.social/post/3l47ij5osb32u",
        image_urls: %w[https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:mymwxdm4zedrqufkotuxn72k&cid=bafkreih2h3eretfhugjzao5af3jc5zxfydsdyvyijhfi7ij4et55jqrqfi],
        media_files: [{ file_size: 1_172_768 }],
        page_url: "https://bsky.app/profile/did:plc:mymwxdm4zedrqufkotuxn72k/post/3l47ij5osb32u",
        profile_urls: %w[https://bsky.app/profile/tuyoki.bsky.social https://bsky.app/profile/did:plc:mymwxdm4zedrqufkotuxn72k],
        display_name: "temmie",
        username: "tuyoki",
        tags: [],
        dtext_artist_commentary_desc: "victory pose",
      )
    end

    context "A post with a video and an alt text" do
      strategy_should_work(
        # note: currently the alt text isn't actually visible from bluesky's web interface, because their native video player doesn't support it
        "https://bsky.app/profile/rningscissors.bsky.social/post/3lozjurmajk25",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          current vibe:

          [quote]
          h6. Video Description

          Timon from The Lion King singing the lyric “disaster’s in the air” from Can You Feel The Love Tonight
          [/quote]
        EOS
      )
    end

    context "A post with unicode alt text" do
      strategy_should_work(
        "https://bsky.app/profile/did:plc:p5mbisiuaimkju4r2uyzyo7s/post/3lnwlami6fk2t",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          見えない

          [quote]
          h6. Image Description

          リスフラ
          [/quote]
        EOS
      )
    end

    context "A post url with DID as user id" do
      strategy_should_work(
        "https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"],
        media_files: [{ file_size: 398_747 }],
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

    context "A post with Unicode tags" do
      strategy_should_work(
        "https://bsky.app/profile/mzmanjo.bsky.social/post/3l46kshfnjt2t",
        image_urls: %w[https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:4ix5icku4nehfgpkyhtrpto6&cid=bafkreiblyhv7hrjeaft44lx2l2kdtqcru5uzqumimnlhqopjh2gvyvm7ca],
        media_files: [{ file_size: 475_001 }],
        page_url: "https://bsky.app/profile/did:plc:4ix5icku4nehfgpkyhtrpto6/post/3l46kshfnjt2t",
        profile_urls: %w[https://bsky.app/profile/mzmanjo.bsky.social https://bsky.app/profile/did:plc:4ix5icku4nehfgpkyhtrpto6],
        display_name: "アンジョー",
        username: "mzmanjo",
        tags: [
          ["100日チャレンジ", "https://bsky.app/hashtag/100日チャレンジ"],
          ["逃げ若", "https://bsky.app/hashtag/逃げ若"],
          ["逃げ上手の若君", "https://bsky.app/hashtag/逃げ上手の若君"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: <<~EOS.chomp,
          8日目 北条時行
          "#100日チャレンジ":[https://bsky.app/hashtag/100日チャレンジ]
          "#逃げ若":[https://bsky.app/hashtag/逃げ若] "#逃げ上手の若君":[https://bsky.app/hashtag/逃げ上手の若君]
        EOS
      )
    end
    context "A post that requires sign-in to view" do
      strategy_should_work(
        "https://bsky.app/profile/masarustrongest.bsky.social/post/3lntvzjfhbs2u",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:pz2wk53vr3jjy3fssbfhndjs&cid=bafkreihcks5qjilktm74zjfqyoh6h2z5kydkyj7ymronl57qfnnj5ugx3y"],
        media_files: [{ file_size: 834_447 }],
        profile_url: "https://bsky.app/profile/masarustrongest.bsky.social",
        profile_urls: [
          "https://bsky.app/profile/masarustrongest.bsky.social",
          "https://bsky.app/profile/did:plc:pz2wk53vr3jjy3fssbfhndjs",
        ],
        page_url: "https://bsky.app/profile/did:plc:pz2wk53vr3jjy3fssbfhndjs/post/3lntvzjfhbs2u",
        display_name: "轟将",
        username: "masarustrongest",
        tags: [],
        dtext_artist_commentary_desc: "Happy 6th Anniversary🌿",
      )
    end

    context "A post from a bluesky instance other than bsky.social" do
      strategy_should_work(
        "https://bsky.app/profile/banditelli.org/post/3lp2aj326uc25",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:555c53zqgqs55yh6gvttf5uv&cid=bafkreibu3cy5u667yqob77q3vlj3f6ifwhs2wkatxcow6qhttipu3qpqny"],
        media_files: [{ file_size: 508_085 }],
        profile_url: "https://bsky.app/profile/banditelli.org",
        profile_urls: [
          "https://bsky.app/profile/banditelli.org",
          "https://bsky.app/profile/did:plc:555c53zqgqs55yh6gvttf5uv",
        ],
        page_url: "https://bsky.app/profile/did:plc:555c53zqgqs55yh6gvttf5uv/post/3lp2aj326uc25",
        display_name: /Banditelli/,
        username: "banditelli",
        tags: [],
        dtext_artist_commentary_desc: <<~EOS.chomp,
          Hops for all. "#birds":[https://bsky.app/hashtag/birds]

          [quote]
          h6. Image Description

          a female western bluebird hopping
          [/quote]
        EOS
      )
    end

    context "A post mentioning another user" do
      strategy_should_work(
        "https://bsky.app/profile/did:plc:hd3rni5gped4mfzeu3qwymoo/post/3lquu2ozng22q",
        html_artist_commentary_desc: 'kofi swimsuit request of <a href="https://bsky.app/profile/did:plc:qp3pms6cajl5wdnr3fjquugn">@darksteele0224.bsky.social</a> \'s OC, Lilac (^-^)',
      )
    end

    context "A 'https://cdn.bsky.app/img' url" do
      strategy_should_work(
        "https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:3jogsxcisdcdzwjobhxbav2w/bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4@jpeg",
        image_urls: ["https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4"],
        media_files: [{ file_size: 398_747 }],
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
  end
end
