require "test_helper"

module Source::Tests::Extractor
  class DouyinExtractorTest < ActiveSupport::ExtractorTestCase
    context "With credentials" do
      setup do
        skip "Douyin credentials not configured" unless Source::Extractor::Douyin.enabled?
      end

      context "An image post" do
        strategy_should_work(
          "https://www.douyin.com/note/7698000683710743973",
          image_urls: [
            %r{\Ahttps://p\d+-pc-sign\.douyinpic\.com/tos-cn-i-0813c000-ce/oAzkAGWIuALZJzpeBg7pkOValG7fqAzeIQxFAl~tplv-dy-aweme-images-v2:3000:3000:q75\.jpeg\?},
            %r{\Ahttps://p\d+-pc-sign\.douyinpic\.com/tos-cn-i-0813c000-ce/ocsrEn4yUDAtySASAMF9E9qADAfw5C21IYfVUE~tplv-dy-aweme-images-v2:3000:3000:q75\.jpeg\?},
            %r{\Ahttps://p\d+-pc-sign\.douyinpic\.com/tos-cn-i-0813c000-ce/oEDSAE9ArIy1UFiA5nSfDYGt9fA5C9wyUqEMAE~tplv-dy-aweme-images-v2:3000:3000:q75\.jpeg\?},
          ],
          media_files: [
            { file_size: 320_664 },
            { file_size: 297_699 },
            { file_size: 139_951 },
          ],
          page_url: "https://www.douyin.com/note/7698000683710743973",
          profile_url: "https://www.douyin.com/user/MS4wLjABAAAA_k-7oWlf3nWgMntx02OOaBXXTbUhNghCdDiYlA9J_myhP-TMLklvdrH4XdwMuqRT",
          profile_urls: %w[https://www.douyin.com/user/MS4wLjABAAAA_k-7oWlf3nWgMntx02OOaBXXTbUhNghCdDiYlA9J_myhP-TMLklvdrH4XdwMuqRT],
          display_name: "软炭",
          username: "rt51",
          published_at: Time.parse("2026-10-18T13:34:14Z"),
          updated_at: nil,
          tags: [
            ["绝区零", "https://www.douyin.com/hashtag/1721909608644612"],
            ["铃", "https://www.douyin.com/hashtag/1592160393194500"],
            ["蕾米埃尔", "https://www.douyin.com/hashtag/7632308794088753190"],
            ["板绘", "https://www.douyin.com/hashtag/1583848187517965"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "摸一张铃和蕾米埃尔(♡>𖥦<)/♥。剧情里提到过铃后面想给蕾米埃尔买小玩偶，所以就画了铃送给蕾米埃尔小小蕾米玩偶😋 #绝区零 #铃 #蕾米埃尔 #板绘",
        )
      end

      context "An image URL with a referer" do
        strategy_should_work(
          "https://p3-pc-sign.douyinpic.com/tos-cn-i-0813c000-ce/oAzkAGWIuALZJzpeBg7pkOValG7fqAzeIQxFAl~tplv-dy-aweme-images-v2:3000:3000:q75.jpeg?lk3s=138a59ce&x-expires=1798444800&x-signature=M5a%2BIPCyNC9hA%2F29J%2FIr%2FVsQp0o%3D&from=327834062&s=PackSourceEnum_AWEME_DETAIL&se=false&sc=image&biz_tag=aweme_images&l=2026112816582032039292DE79EDC884C2",
          referer: "https://www.douyin.com/note/7698000683710743973",
          image_urls: %w[https://p3-pc-sign.douyinpic.com/tos-cn-i-0813c000-ce/oAzkAGWIuALZJzpeBg7pkOValG7fqAzeIQxFAl~tplv-dy-aweme-images-v2:3000:3000:q75.jpeg?lk3s=138a59ce&x-expires=1798444800&x-signature=M5a%2BIPCyNC9hA%2F29J%2FIr%2FVsQp0o%3D&from=327834062&s=PackSourceEnum_AWEME_DETAIL&se=false&sc=image&biz_tag=aweme_images&l=2026112816582032039292DE79EDC884C2],
          media_files: [{ file_size: 320_664 }],
          page_url: "https://www.douyin.com/note/7698000683710743973",
          profile_url: "https://www.douyin.com/user/MS4wLjABAAAA_k-7oWlf3nWgMntx02OOaBXXTbUhNghCdDiYlA9J_myhP-TMLklvdrH4XdwMuqRT",
          profile_urls: %w[https://www.douyin.com/user/MS4wLjABAAAA_k-7oWlf3nWgMntx02OOaBXXTbUhNghCdDiYlA9J_myhP-TMLklvdrH4XdwMuqRT],
          display_name: "软炭",
          username: "rt51",
          published_at: Time.parse("2026-10-18T09:34:14.000000-04:00"),
          updated_at: nil,
          tags: [
            ["绝区零", "https://www.douyin.com/hashtag/1721909608644612"],
            ["铃", "https://www.douyin.com/hashtag/1592160393194500"],
            ["蕾米埃尔", "https://www.douyin.com/hashtag/7632308794088753190"],
            ["板绘", "https://www.douyin.com/hashtag/1583848187517965"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "摸一张铃和蕾米埃尔(♡>𖥦<)/♥。剧情里提到过铃后面想给蕾米埃尔买小玩偶，所以就画了铃送给蕾米埃尔小小蕾米玩偶😋 #绝区零 #铃 #蕾米埃尔 #板绘",
        )
      end

      context "A video post" do
        strategy_should_work(
          "https://www.douyin.com/video/7524660855435988284",
          image_urls: [%r{\Ahttps://www\.douyin\.com/aweme/v1/play/\?video_id=v1e00fgi0000d1mfe5vog65vhen11m4g&}],
          media_files: [{ file_size: 11_889_604 }],
          page_url: "https://www.douyin.com/video/7524660855435988284",
          profile_url: "https://www.douyin.com/user/MS4wLjABAAAArVowWpSpfDrmhemjLt-b97mizJvm5q9cdJw1aCzdn2jZCbvT-xhW7bhJuDf6GX1L",
          profile_urls: %w[https://www.douyin.com/user/MS4wLjABAAAArVowWpSpfDrmhemjLt-b97mizJvm5q9cdJw1aCzdn2jZCbvT-xhW7bhJuDf6GX1L],
          display_name: "耑江古木",
          username: "43660241834",
          published_at: Time.parse("2025-07-08T10:47:12Z"),
          updated_at: nil,
          tags: [
            ["oc动画", "https://www.douyin.com/hashtag/1703988535827463"],
            ["指绘", "https://www.douyin.com/hashtag/1580414576356365"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "【结企指绘动画+倍速过程】 #oc动画 #指绘 今天结企but没画完，于是草草结尾。很短的一点。 第一次玩企划，好热闹的来着！💗💗感觉群里设定都好可爱！💗😋",
        )
      end

      context "A shortened share link" do
        strategy_should_work(
          "https://v.douyin.com/znwIiWQwdiU/",
          image_urls: [%r{\Ahttps://www\.douyin\.com/aweme/v1/play/\?video_id=v1e00fgi0000d1mfe5vog65vhen11m4g&}],
          media_files: [{ file_size: 11_889_604 }],
          page_url: "https://www.douyin.com/video/7524660855435988284",
          profile_url: "https://www.douyin.com/user/MS4wLjABAAAArVowWpSpfDrmhemjLt-b97mizJvm5q9cdJw1aCzdn2jZCbvT-xhW7bhJuDf6GX1L",
          profile_urls: %w[https://www.douyin.com/user/MS4wLjABAAAArVowWpSpfDrmhemjLt-b97mizJvm5q9cdJw1aCzdn2jZCbvT-xhW7bhJuDf6GX1L],
          display_name: "耑江古木",
          username: "43660241834",
          published_at: Time.parse("2025-07-08T06:47:12.000000-04:00"),
          updated_at: nil,
          tags: [
            ["oc动画", "https://www.douyin.com/hashtag/1703988535827463"],
            ["指绘", "https://www.douyin.com/hashtag/1580414576356365"],
          ],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "【结企指绘动画+倍速过程】 #oc动画 #指绘 今天结企but没画完，于是草草结尾。很短的一点。 第一次玩企划，好热闹的来着！💗💗感觉群里设定都好可爱！💗😋",
        )
      end

      context "A deleted or private post" do
        strategy_should_work(
          "https://www.douyin.com/video/7127940372856114467",
          deleted: true,
          image_urls: [],
          page_url: "https://www.douyin.com/video/7127940372856114467",
          profile_url: nil,
          profile_urls: [],
          display_name: nil,
          username: nil,
          published_at: nil,
          updated_at: nil,
          tags: [],
          dtext_artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
        )
      end
    end

    # A canary for when the extractor breaks. Douyin's API rejects requests unless they're signed with a salt from
    # Douyin's security SDK, so this fails if the salt in Source::Extractor::Douyin isn't in the SDK anymore. It doesn't
    # need credentials.
    context "Douyin's security SDK" do
      should "contain the salt used to sign API requests" do
        js = Danbooru::Http.external.get("https://lf-security.bytegoofy.com/obj/security-secsdk/runtime_bundler_34.js").to_s

        # The SDK runs bytecode programs stored as hex strings, like "504B0101f2a703e5000014c8e603a4f1...".
        strings = js.scan(/"(504B\h{200,})"/).flatten.flat_map { |program| vm_strings(program) }
        candidates = strings.grep(/\A[0-9A-F]{32}\z/)

        assert_includes(strings, Source::Extractor::Douyin::SIGNATURE_SALT, "The salt changed. Candidates for the new salt: #{candidates.inspect}")
      end
    end

    # Decode a program's string table, like the SDK's bytecode interpreter does. The program is a hex string with this layout:
    #
    # * 4 bytes: "PK\x01\x01" header
    # * 4 bytes: the XOR key for the strings is in the low 2 bits of each byte
    # * 8 bytes: other fields
    # * 4 bytes: bytecode length, followed by the bytecode
    # * 2 bytes: number of strings, followed by the strings. Each string is a length, then that many XORed characters,
    #   all stored as varints.
    def vm_strings(hex)
      key = 4.times.sum { |n| (hex[8 + (2 * n), 2].to_i(16) & 3) << (2 * n) }
      pos = 40 + (2 * hex[32, 8].to_i(16))
      count = hex[pos, 4].to_i(16)
      pos += 4

      count.times.map do
        size, length = read_varint(hex, pos)
        pos += 2 * size

        length.times.map do
          size, char = read_varint(hex, pos)
          pos += 2 * size
          (char ^ key).chr(Encoding::UTF_8)
        end.join
      end
    end

    # Read a 1, 2, or 3 byte varint. The top bits of the first byte give the size: 0xxxxxxx is 1 byte, 10xxxxxx is 2
    # bytes, and 11xxxxxx is 3 bytes.
    #
    # @return [Array<(Integer, Integer)>] The size in bytes, and the value.
    def read_varint(hex, pos)
      byte = hex[pos, 2].to_i(16)

      if byte >> 7 == 0
        [1, byte]
      elsif byte >> 6 == 2
        [2, ((byte & 63) << 8) + hex[pos + 2, 2].to_i(16)]
      else
        [3, ((byte & 63) << 16) + hex[pos + 2, 4].to_i(16)]
      end
    end
  end
end
