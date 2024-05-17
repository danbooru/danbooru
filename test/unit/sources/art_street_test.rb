require 'test_helper'

module Sources
  class ArtStreetTest < ActiveSupport::TestCase
    context "ArtStreet:" do
      context "A https://medibang.com/picture/:id/ page url" do
        strategy_should_work(
          "https://medibang.com/picture/4b2112261505098280008769655/",
          page_url: "https://medibang.com/picture/4b2112261505098280008769655/",
          image_urls: %w[
            https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png
            https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/9a500170-4995-446e-8c9d-eb69fa325485.png
          ],
          profile_url: "https://medibang.com/author/8769655/",
          profile_urls: %w[
            https://medibang.com/u/16672238/
            https://medibang.com/author/8769655/
          ],
          display_name: "PogoRabbit",
          tag_name: "pogorabbit",
          other_names: ["PogoRabbit"],
          tags: %w[hutao Zhongli(GenshinImpact) GenshinImpact],
          artist_commentary_title: "Wangshen funeral partners",
          dtext_artist_commentary_desc: "Idk but this was so much fun to draw! :D",
        )
      end

      context "A picture sample image url" do
        strategy_should_work(
          "https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/1280_960/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png",
          page_url: "https://medibang.com/picture/4b2112261505098280008769655/",
          image_urls: %w[
            https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png
          ],
          media_files: [{ file_size: 6_650_948 }],
          profile_url: "https://medibang.com/author/8769655/",
          profile_urls: %w[
            https://medibang.com/u/16672238/
            https://medibang.com/author/8769655/
          ],
          display_name: "PogoRabbit",
          tag_name: "pogorabbit",
          other_names: ["PogoRabbit"],
          tags: %w[hutao Zhongli(GenshinImpact) GenshinImpact],
          artist_commentary_title: "Wangshen funeral partners",
          dtext_artist_commentary_desc: "Idk but this was so much fun to draw! :D",
        )
      end

      context "A book image url" do
        strategy_should_work(
          "https://dqmk835cy5zzx.cloudfront.net/f7/current/f72107281839259430002176282/798080e1-1361-49c0-84aa-06518bdf1a22.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kcW1rODM1Y3k1enp4LmNsb3VkZnJvbnQubmV0L2Y3L2N1cnJlbnQvZjcyMTA3MjgxODM5MjU5NDMwMDAyMTc2MjgyLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODAxMTU0NTR9fX1dfQ__&Signature=cmqcwnTqKcMtc1-8kRVGsGiDQzQPjeNuEvzhHjiUt7WLJ8DKzUAHvQQwMjh4hBdFFUk19oTM3zGV0qfOffnqRP9EMhXjMxxHG1IngryfdnPfbyHyEIRg~lpW3LNjv-ZKBx8EYDIO1P-1XT2Xi6YZwphv7SIZrhmSyT2TOfXiayJhqWeIBs6MF2UMuDwn2KxRroRNsf09v3jtKQdx1YQzNzIhQWDmInxF7ml2HyxDOCNxKHJkCpzI7H2x7M-s-AZDoj-~x7LfJDpNwOK~TdGrmjBz8BCNgU3q9vrj-iOos4PwnY8awimIVDaXuf~UaHAyWueP2IgB6z4QrQDQ8m1dBw__&Key-Pair-Id=APKAI322DZTKDWD5CY2Q",
          page_url: "https://medibang.com/book/f72107281839259430002176282/",
          image_urls: %w[
            https://dqmk835cy5zzx.cloudfront.net/f7/current/f72107281839259430002176282/798080e1-1361-49c0-84aa-06518bdf1a22.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kcW1rODM1Y3k1enp4LmNsb3VkZnJvbnQubmV0L2Y3L2N1cnJlbnQvZjcyMTA3MjgxODM5MjU5NDMwMDAyMTc2MjgyLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODAxMTU0NTR9fX1dfQ__&Signature=cmqcwnTqKcMtc1-8kRVGsGiDQzQPjeNuEvzhHjiUt7WLJ8DKzUAHvQQwMjh4hBdFFUk19oTM3zGV0qfOffnqRP9EMhXjMxxHG1IngryfdnPfbyHyEIRg~lpW3LNjv-ZKBx8EYDIO1P-1XT2Xi6YZwphv7SIZrhmSyT2TOfXiayJhqWeIBs6MF2UMuDwn2KxRroRNsf09v3jtKQdx1YQzNzIhQWDmInxF7ml2HyxDOCNxKHJkCpzI7H2x7M-s-AZDoj-~x7LfJDpNwOK~TdGrmjBz8BCNgU3q9vrj-iOos4PwnY8awimIVDaXuf~UaHAyWueP2IgB6z4QrQDQ8m1dBw__&Key-Pair-Id=APKAI322DZTKDWD5CY2Q
          ],
          profile_url: "https://medibang.com/author/2176282/",
          profile_urls: %w[
            https://medibang.com/u/littlegfu3/
            https://medibang.com/author/2176282/
          ],
          display_name: "丸思綺",
          other_names: ["丸思綺"],
          tags: %w[school drama 生活 小故事大道理],
          artist_commentary_title: "Ch. 1 居家的禮儀",
          dtext_artist_commentary_desc: <<~EOS.chomp
            在家裡面養成生活的好習慣，早睡早起精神好，衣服棉被要摺好，早安晚安每天說!!
            【居家的禮儀】
            一、為人子不晏起，衣被自己整理，晨昏必定省。
            二、為人子坐不中席，行不中道。
            三、為人子出必告，反必面。
            四、長者與物，須兩手奉接。
            五、徐行後長，不疾行先長。
            六、長者立不可坐，長者來必起立。
            七、不在長者座前踱來踱去。
            八、立不中門，過門不踐門限。
            九、立不一足跛，坐勿展腳如箕，睡眠不仰不伏，右臥如弓。
            十、同桌吃飯不另備美食獨啖。
            十一、不挑剔食之美惡。
            十二、食時不歎，不訓斥子弟。
          EOS
        )
      end

      context "A book page url" do
        strategy_should_work(
          "https://medibang.com/book/f72107281839259430002176282/",
          page_url: "https://medibang.com/book/f72107281839259430002176282/",
          image_urls: [
            "https://dthezntil550i.cloudfront.net/f7/current/f72107281839259430002176282/0936fedf-f270-442b-bd75-a44c4c392198.jpg",
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/798080e1-1361-49c0-84aa-06518bdf1a22\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/8ac41039-c2e8-489c-a9d8-a45cc52362bb\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/6d82f53c-fa71-4bb9-b509-9712413adfa7\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/ffdcc5ae-f2f6-4323-b0ad-3c56f9d8345a\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/2cdb3c5e-44ff-4c3d-a14f-a2cc79f22ad9\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/2600e171-904d-40e9-8ba5-b9038b4728d8\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/ee5833ac-c95c-49a0-8cb9-fd7c5b91e7c9\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/794beb02-4fb3-4c0b-af58-d0420dbf176f\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/a94401e8-d8c2-4b5c-b0e2-c3e0a3491b22\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/bcdf82c8-c294-4307-b295-24589b652c02\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/28c01425-77a4-4516-82d9-48e6f657430e\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/3ff56449-0fe7-47c9-a22d-c60d91d4e44b\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/5371b12f-785d-4469-82e8-93d0bcc517ea\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/d7a86383-64ed-444f-91af-09a0f10de35f\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/330c0e32-b674-416a-bed0-33176f544237\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/ea4d5a66-d1fd-4b88-9886-aee202e825a4\.jpg},
            %r{https://dqmk835cy5zzx\.cloudfront\.net/f7/current/f72107281839259430002176282/5fbdec9e-5b17-469d-9c37-6f39e19524c1\.jpg},
          ],
          profile_url: "https://medibang.com/author/2176282/",
          profile_urls: %w[
            https://medibang.com/u/littlegfu3/
            https://medibang.com/author/2176282/
          ],
          display_name: "丸思綺",
          other_names: ["丸思綺"],
          tags: %w[school drama 生活 小故事大道理],
          artist_commentary_title: "Ch. 1 居家的禮儀",
          dtext_artist_commentary_desc: <<~EOS.chomp
            在家裡面養成生活的好習慣，早睡早起精神好，衣服棉被要摺好，早安晚安每天說!!
            【居家的禮儀】
            一、為人子不晏起，衣被自己整理，晨昏必定省。
            二、為人子坐不中席，行不中道。
            三、為人子出必告，反必面。
            四、長者與物，須兩手奉接。
            五、徐行後長，不疾行先長。
            六、長者立不可坐，長者來必起立。
            七、不在長者座前踱來踱去。
            八、立不中門，過門不踐門限。
            九、立不一足跛，坐勿展腳如箕，睡眠不仰不伏，右臥如弓。
            十、同桌吃飯不另備美食獨啖。
            十一、不挑剔食之美惡。
            十二、食時不歎，不訓斥子弟。
          EOS
        )
      end

      context "A picture page url for an artist without a /u/:id profile" do
        strategy_should_work(
          "https://medibang.com/picture/0h1701050329209270000749476",
          page_url: "https://medibang.com/picture/0h1701050329209270000749476/",
          image_urls: %w[
            https://dthezntil550i.cloudfront.net/0h/latest/0h1701050329209270000749476/a688c4d7-c448-4867-9c31-10c59c5a4007.jpg
          ],
          profile_url: "https://medibang.com/author/749476/",
          profile_urls: %w[
            https://medibang.com/author/749476/
          ],
          display_name: "チッタ",
          other_names: ["チッタ"],
          tags: [],
          artist_commentary_title: "空想に浸る",
          dtext_artist_commentary_desc: "",
        )
      end

      context "A R-18 page url" do
        strategy_should_work(
          "https://medibang.com/picture/ln1908221547595430010136798/",
          page_url: "https://medibang.com/picture/ln1908221547595430010136798/",
          image_urls: ["https://dthezntil550i.cloudfront.net/ln/latest/ln1908221547595430010136798/922ad884-b010-498c-a979-50e9a464fee3.png"],
          media_files: [{ file_size: 827_822 }],
          profile_url: "https://medibang.com/author/10136798/",
          profile_urls: %w[
            https://medibang.com/author/10136798/
            https://medibang.com/u/Sweetie/
          ],
          display_name: "아시아꿈",
          other_names: ["아시아꿈"],
          tags: %w[R-18 furry hatsunemiku Ecchi anthro medibangpaint Butt Lewd],
          artist_commentary_title: "하츠네 미쿠 (R-18)",
          dtext_artist_commentary_desc: <<~EOS.chomp
            Do not reprint to other website
            다른 웹 사이트로 무단 전재 금지
          EOS
        )
      end

      context "A deleted page url" do
        strategy_should_work(
          "https://medibang.com/picture/i51604010226402270000329446/",
          page_url: "https://medibang.com/picture/i51604010226402270000329446/",
          image_urls: [],
          profile_url: "https://medibang.com/author/329446/",
          profile_urls: %w[
            https://medibang.com/author/329446/
          ],
          display_name: nil,
          other_names: [],
          tags: [],
          artist_commentary_title: "",
          dtext_artist_commentary_desc: "",
        )
      end

      should "Parse ArtStreet URLs correctly" do
        assert(Source::URL.image_url?("https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/1280_960/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png"))
        assert(Source::URL.image_url?("https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png"))
        assert(Source::URL.image_url?("https://dqmk835cy5zzx.cloudfront.net/f7/current/f72107281839259430002176282/798080e1-1361-49c0-84aa-06518bdf1a22.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kcW1rODM1Y3k1enp4LmNsb3VkZnJvbnQubmV0L2Y3L2N1cnJlbnQvZjcyMTA3MjgxODM5MjU5NDMwMDAyMTc2MjgyLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODAxMTMzNzB9fX1dfQ__&Signature=QG35KafzMXXY1hlsXnJHKnlZYU~hBrduhfh-StKFhudNRLNFbidoeGsF1pnVhyeHJQNdRkRg6WwErw-q35HIZLxoC5ugWY64tdnY-l6H1rI-M2mSIiMkYEDUP6mqBXCgObZaCV6Lk6b18s~trzbXbYO9cMVDvJ5DSvMJb1f1G~pDBbSsgulVRNUppQcPqjM3ObvRqsRtEMxwjuafEJ33JmfVTr-hUzk-ncTL-MegEiC7qFaT0o08cHKXO4385JBUt8S6ZcNch-EvNbEXIxUsK-XH-VeAy93cuJ~Ez0VioZarwlFejXH0K--b2lzwwroqGfke4gVFH0I4Skc4GVnF9g__&Key-Pair-Id=APKAI322DZTKDWD5CY2Q"))

        assert(Source::URL.page_url?("https://medibang.com/picture/4b2112261505098280008769655/"))
        assert(Source::URL.page_url?("https://medibang.com/book/f72107281839259430002176282/"))
        assert(Source::URL.page_url?("https://medibang.com/viewer/f72107281839259430002176282/"))

        assert(Source::URL.profile_url?("https://medibang.com/author/8769655"))
        assert(Source::URL.profile_url?("https://medibang.com/author/749476/gallery/?cat=illust"))
        assert(Source::URL.profile_url?("https://medibang.com/u/16672238/"))
        assert(Source::URL.profile_url?("https://medibang.com/u/16672238/gallery/?cat=comic"))
        assert(Source::URL.profile_url?("https://medibang.com/u/littlegfu3/"))
      end
    end
  end
end
