require "test_helper"

module Sources
  class GelbooruTest < ActiveSupport::TestCase
    context "A Gelbooru direct image url without a referer" do
      strategy_should_work(
        "https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬GREYASH",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_hat witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        media_files: [{ file_size: 480_621 }]
      )
    end

    context "A Gelbooru direct image url with a referer" do
      strategy_should_work(
        "https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg",
        referer: "https://gelbooru.com/index.php?page=post&s=view&id=7798121",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬GREYASH",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_hat witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        media_files: [{ file_size: 480_621 }]
      )
    end

    context "A Gelbooru sample image url" do
      strategy_should_work(
        "https://img3.gelbooru.com/samples/04/f2/sample_04f2767c64593c3030ce74ecc2528704.jpg",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬GREYASH",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_hat witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        media_files: [{ file_size: 480_621 }]
      )
    end

    context "A Gelbooru page url" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=view&id=7798121",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬GREYASH",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_hat witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        media_files: [{ file_size: 480_621 }]
      )
    end

    context "A Gelbooru md5 page url" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=list&md5=04f2767c64593c3030ce74ecc2528704",
        image_urls: ["https://img3.gelbooru.com/images/04/f2/04f2767c64593c3030ce74ecc2528704.jpg"],
        artist_name: "灰色灰烬GREYASH",
        profile_url: "https://www.pixiv.net/users/3330425",
        tags: %w[1girl back_bow black_pantyhose blue_bow blue_hair blue_ribbon boots bow cape chibi chinese_commentary closed_eyes full_body hair_between_eyes hair_ribbon hat hatsune_miku indai_(3330425) on_ground pantyhose pom_pom_(clothes) rabbit rabbit_yukine rating:general ribbon simple_background sitting solo twintails vocaloid white_background white_cape white_hat witch_hat yuki_miku yuki_miku_(2014) 初音ミク 雪ミク],
        artist_commentary_title: "2010~2021雪ミク",
        artist_commentary_desc: "动作参考@速写班长",
        media_files: [{ file_size: 480_621 }]
      )
    end

    context "A deleted Gelbooru post" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=list&md5=9d06e876937d46eeda7a5e0ca52f63a8",
        image_urls: [],
        artist_name: nil,
        profile_url: nil,
        tags: %w[],
        artist_commentary_title: nil,
        artist_commentary_desc: nil
      )
    end

    context "A nonexistent Gelbooru post" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=list&md5=ffffffffffffffffffffffffffffffff",
        image_urls: [],
        artist_name: nil,
        profile_url: nil,
        tags: %w[],
        artist_commentary_title: nil,
        artist_commentary_desc: nil
      )
    end

    context "A sourceless Gelbooru post" do
      strategy_should_work(
        "https://gelbooru.com/index.php?page=post&s=view&id=706722",
        image_urls: ["https://img3.gelbooru.com/images/c3/a8/c3a86e901159d971448044b16ac72c4c.jpg"],
        artist_name: nil,
        profile_url: nil,
        profile_urls: [],
        other_names: [],
        tags: [],
        artist_commentary_title: nil,
        artist_commentary_desc: nil
      )
    end

    context "A Gelbooru post with a malformed Pixiv source URL" do
      strategy_should_work(
        # source: "https://www.pixiv.net/artworks/99176572 [Direct link in description]"
        "https://gelbooru.com/index.php?page=post&s=view&id=7868427",
        image_urls: ["https://video-cdn1.gelbooru.com/images/e7/88/e788470bf83be1e8eba72ca9cca8f738.mp4"],
        artist_name: nil,
        artist_commentary_title: nil,
        artist_commentary_desc: nil
      )
    end

    should "normalize gelbooru links" do
      source1 = "https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg"
      source2 = "http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png"
      source3 = "https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg"

      assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e", Source::URL.page_url(source1))
      assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531", Source::URL.page_url(source2))
      assert_equal("https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c", Source::URL.page_url(source3))
    end

    context "Safebooru:" do
      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://safebooru.org/images/$dir/$hash.jpg?$post_id URL without a referer" do
        strategy_should_work(
          "https://safebooru.org//images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg?4189916",
          image_urls: ["https://safebooru.org//images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg?4189916"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim long_hair looking_at_viewer make_up_in_halloween!_(umamusume) official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt skirt_bow solo spider_web_print standing star_ornament twitter_username umamusume violet_eyes white_shirt wings rating:q ウマ娘 ライスシャワー ハロウィンイラスト 二次創作 ウマ娘プリティーダービー ライスシャワー(ウマ娘) 更衣室 Make_up_Vampire! ドラキュライス 困り顔],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://safebooru.org/images/$dir/$hash.jpg URL without a referer" do
        strategy_should_work(
          "https://safebooru.org//images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg",
          image_urls: ["https://safebooru.org//images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: nil,
          profile_url: nil,
          tags: [],
          artist_commentary_title: nil,
          artist_commentary_desc: nil
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://safebooru.org/images/$dir/$hash.jpg URL with a referer" do
        strategy_should_work(
          "https://safebooru.org//images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg",
          referer: "https://safebooru.org/index.php?page=post&s=view&id=4189916",
          image_urls: ["https://safebooru.org//images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim long_hair looking_at_viewer make_up_in_halloween!_(umamusume) official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt skirt_bow solo spider_web_print standing star_ornament twitter_username umamusume violet_eyes white_shirt wings rating:q ウマ娘 ライスシャワー ハロウィンイラスト 二次創作 ウマ娘プリティーダービー ライスシャワー(ウマ娘) 更衣室 Make_up_Vampire! ドラキュライス 困り顔],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://safebooru.org/index.php?page=post&s=view&id=$post_id URL" do
        strategy_should_work(
          "https://safebooru.org/index.php?page=post&s=view&id=4189916",
          image_urls: ["https://safebooru.org/images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim long_hair looking_at_viewer make_up_in_halloween!_(umamusume) official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt skirt_bow solo spider_web_print standing star_ornament twitter_username umamusume violet_eyes white_shirt wings rating:q ウマ娘 ライスシャワー ハロウィンイラスト 二次創作 ウマ娘プリティーダービー ライスシャワー(ウマ娘) 更衣室 Make_up_Vampire! ドラキュライス 困り顔],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://safebooru.org/index.php?page=post&s=list&md5=$md5 URL" do
        strategy_should_work(
          "https://safebooru.org/index.php?page=post&s=list&md5=8ca0f76e014175f11085d64932d980a5",
          image_urls: ["https://safebooru.org/images/4010/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim long_hair looking_at_viewer make_up_in_halloween!_(umamusume) official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt skirt_bow solo spider_web_print standing star_ornament twitter_username umamusume violet_eyes white_shirt wings rating:q ウマ娘 ライスシャワー ハロウィンイラスト 二次創作 ウマ娘プリティーダービー ライスシャワー(ウマ娘) 更衣室 Make_up_Vampire! ドラキュライス 困り顔],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://safebooru.org/images/$dir/$md5.jpg URL without a referer" do
        strategy_should_work(
          "https://safebooru.org//images/4016/64779fbfc87020ed5fd94854fe973bc0.jpeg",
          image_urls: ["https://safebooru.org//images/4016/64779fbfc87020ed5fd94854fe973bc0.jpeg"],
          artist_name: nil,
          profile_url: nil,
          tags: %w[
            black_blindfold black_dress black_footwear black_hairband black_legwear blindfold boots breasts brown_eyes
            cleavage_cutout d4dj dress gloves hairband high_heel_boots high_heels holding juliet_sleeves leotard
            long_hair long_sleeves medium_breasts mole mole_under_mouth pink_hair puffy_sleeves rating:s short_hair
            silver_hair sword tassel thigh_boots thighhighs thighhighs_under_boots vambraces weapon yano_hiiro
            yorha_no._2_type_b
          ],
          artist_commentary_title: nil,
          artist_commentary_desc: nil
        )
      end
    end

    context "TBIB:" do
      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://tbib.org/images/$dir/$hash.jpg?$post_id URL without a referer" do
        strategy_should_work(
          "https://tbib.org//images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg?11480218",
          image_urls: ["https://tbib.org//images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg?11480218"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bow_skirt bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim locker locker_room long_hair looking_at_viewer make_up_vampire! official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves purple_eyes rating:q rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt solo spider_web_print standing star_ornament twitter_username umamusume white_shirt wings ウマ娘 ウマ娘プリティーダービー ドラキュライス ハロウィンイラスト ライスシャワー ライスシャワー(ウマ娘) 二次創作 困り顔 更衣室],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://tbib.org/images/$dir/$hash.jpg URL without a referer" do
        strategy_should_work(
          "https://tbib.org//images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg",
          image_urls: ["https://tbib.org//images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: nil,
          profile_url: nil,
          tags: [],
          artist_commentary_title: nil,
          artist_commentary_desc: nil
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://tbib.org/images/$dir/$hash.jpg URL with a referer" do
        strategy_should_work(
          "https://tbib.org//images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg",
          referer: "https://tbib.org/index.php?page=post&s=view&id=11480218",
          image_urls: ["https://tbib.org//images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bow_skirt bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim locker locker_room long_hair looking_at_viewer make_up_vampire! official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves purple_eyes rating:q rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt solo spider_web_print standing star_ornament twitter_username umamusume white_shirt wings ウマ娘 ウマ娘プリティーダービー ドラキュライス ハロウィンイラスト ライスシャワー ライスシャワー(ウマ娘) 二次創作 困り顔 更衣室],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://tbib.org/index.php?page=post&s=view&id=$post_id URL" do
        strategy_should_work(
          "https://tbib.org/index.php?page=post&s=view&id=11480218",
          image_urls: ["https://tbib.org/images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bow_skirt bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim locker locker_room long_hair looking_at_viewer make_up_vampire! official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves purple_eyes rating:q rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt solo spider_web_print standing star_ornament twitter_username umamusume white_shirt wings ウマ娘 ウマ娘プリティーダービー ドラキュライス ハロウィンイラスト ライスシャワー ライスシャワー(ウマ娘) 二次創作 困り顔 更衣室],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end

      # source: https://i.pximg.net/img-original/img/2021/10/24/09/53/44/93646177_p0.jpg
      context "A https://tbib.org/index.php?page=post&s=list&md5=$md5 URL" do
        strategy_should_work(
          "https://tbib.org/index.php?page=post&s=list&md5=8ca0f76e014175f11085d64932d980a5",
          image_urls: ["https://tbib.org/images/10725/febe33d5f6d46e21c073289bb9884d4e0630761c.jpg"],
          artist_name: "チー之介",
          profile_url: "https://www.pixiv.net/users/57673194",
          tags: %w[1girl ^^^ animal_ears black_bow black_bowtie black_gloves black_hair black_hairband black_skirt black_wings blue_flower blue_rose bow bow_skirt bowtie brooch center_frills changing_room cheesecake_(artist) collared_shirt commentary dated demon_wings fangs flower flying_sweatdrops frilled_hairband frilled_sleeves frills frown gloves hair_flower hair_ornament hair_over_one_eye hairband halloween halloween_costume high-waist_skirt highres horse_ears horse_girl indoors jack-o'-lantern_ornament jewelry lace-trimmed_gloves lace_trim locker locker_room long_hair looking_at_viewer make_up_vampire! official_alternate_costume open_mouth orange_bow puffy_short_sleeves puffy_sleeves purple_eyes rating:q rice_shower_(make_up_vampire!)_(umamusume) rice_shower_(umamusume) rose shirt short_sleeves skirt solo spider_web_print standing star_ornament twitter_username umamusume white_shirt wings ウマ娘 ウマ娘プリティーダービー ドラキュライス ハロウィンイラスト ライスシャワー ライスシャワー(ウマ娘) 二次創作 困り顔 更衣室],
          artist_commentary_title: "ハロウィンライス",
          artist_commentary_desc: "更衣室でハロウィン衣装に着替えたあと「がおーっ！」のポーズを鏡の前で密かに練習してたら、見つかっちゃってあわてるライスシャワーを描きました。",
          media_files: [{ file_size: 771_175 }]
        )
      end
    end

    context "Rule34.xxx:" do
      # source: https://twitter.com/marushin_0214/status/1590260107405053954
      context "A https://rule34.xxx/index.php?page=post&s=view&id=$post_id URL" do
        strategy_should_work(
          "https://rule34.xxx/index.php?page=post&s=view&id=6961597",
          image_urls: ["https://api-cdn.rule34.xxx/images/6120/0a8fff70045826d2b39fcde4eed17584.jpeg"],
          artist_name: "丸新(MaruShin)",
          profile_url: "https://twitter.com/marushin_0214",
          tags: %w[bangs big_breasts black_shirt bloomers blue_archive blue_eyes blue_hair blue_jacket blush breasts buruma check_commentary commentary commentary_request cowboy_shot curvy female gym_uniform halo highres holding hourglass_figure huge_breasts jacket lanyard large_breasts long_hair looking_at_viewer marushin_(denwa0214) millennium_science_school_logo_(blue_archive) millennium_science_school_student official_alternate_costume parted_lips partially_unzipped rating:e seminar_(blue_archive) shirt short_sleeves shorts simple_background solo student_id sweat thick_thighs thigh_gap undressing voluptuous wet wet_clothes wet_shirt white_background yuuka_(blue_archive) yuuka_(gym_uniform)_(blue_archive)],
          artist_commentary_desc: "いっぱい走ったね… https://t.co/n3ic5BIONP",
          media_files: [{ file_size: 201_643 }]
        )
      end

      # source: https://twitter.com/marushin_0214/status/1590260107405053954
      context "A https://rule34.xxx/index.php?page=post&s=list&md5=$md5 URL" do
        strategy_should_work(
          "https://rule34.xxx/index.php?page=post&s=list&md5=0a8fff70045826d2b39fcde4eed17584",
          image_urls: ["https://api-cdn.rule34.xxx/images/6120/0a8fff70045826d2b39fcde4eed17584.jpeg"],
          artist_name: "丸新(MaruShin)",
          profile_url: "https://twitter.com/marushin_0214",
          tags: %w[bangs big_breasts black_shirt bloomers blue_archive blue_eyes blue_hair blue_jacket blush breasts buruma check_commentary commentary commentary_request cowboy_shot curvy female gym_uniform halo highres holding hourglass_figure huge_breasts jacket lanyard large_breasts long_hair looking_at_viewer marushin_(denwa0214) millennium_science_school_logo_(blue_archive) millennium_science_school_student official_alternate_costume parted_lips partially_unzipped rating:e seminar_(blue_archive) shirt short_sleeves shorts simple_background solo student_id sweat thick_thighs thigh_gap undressing voluptuous wet wet_clothes wet_shirt white_background yuuka_(blue_archive) yuuka_(gym_uniform)_(blue_archive)],
          artist_commentary_desc: "いっぱい走ったね… https://t.co/n3ic5BIONP",
          media_files: [{ file_size: 201_643 }]
        )
      end

      # source: https://twitter.com/marushin_0214/status/1590260107405053954
      context "A https://rule34.xxx/images/$dir/$md5.jpg URL without a referer" do
        strategy_should_work(
          "https://rule34.xxx//images/6120/0a8fff70045826d2b39fcde4eed17584.jpeg?6961597",
          image_urls: ["https://rule34.xxx//images/6120/0a8fff70045826d2b39fcde4eed17584.jpeg?6961597"],
          artist_name: "丸新(MaruShin)",
          profile_url: "https://twitter.com/marushin_0214",
          tags: %w[bangs big_breasts black_shirt bloomers blue_archive blue_eyes blue_hair blue_jacket blush breasts buruma check_commentary commentary commentary_request cowboy_shot curvy female gym_uniform halo highres holding hourglass_figure huge_breasts jacket lanyard large_breasts long_hair looking_at_viewer marushin_(denwa0214) millennium_science_school_logo_(blue_archive) millennium_science_school_student official_alternate_costume parted_lips partially_unzipped rating:e seminar_(blue_archive) shirt short_sleeves shorts simple_background solo student_id sweat thick_thighs thigh_gap undressing voluptuous wet wet_clothes wet_shirt white_background yuuka_(blue_archive) yuuka_(gym_uniform)_(blue_archive)],
          artist_commentary_desc: "いっぱい走ったね… https://t.co/n3ic5BIONP",
          media_files: [{ file_size: 201_643 }]
        )
      end

      should "normalize rule34.xxx links" do
        source = "https://us.rule34.xxx//images/1802/0adc8fa0604dc445b4b47e6f4c436a08.jpeg?1949807"
        assert_equal("https://rule34.xxx/index.php?page=post&s=view&id=1949807", Source::URL.page_url(source))
      end
    end
  end
end
