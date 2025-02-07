require 'test_helper'

module Sources
  class E621Test < ActiveSupport::TestCase
    context "A normal post URL" do
      strategy_should_work(
        "https://e621.net/posts/3728701",
        image_urls: %w[https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png],
        media_files: [{ file_size: 1_563_179 }],
        page_url: "https://e621.net/posts/3728701",
        profile_urls: %w[https://www.pixiv.net/users/1549213 https://www.pixiv.net/stacc/daga2626],
        display_name: "DAGASI",
        username: "daga2626",
        tags: [
          ["acting_like_a_cat", "https://e621.net/posts?tags=acting_like_a_cat"],
          ["ambiguous_gender", "https://e621.net/posts?tags=ambiguous_gender"],
          ["bath", "https://e621.net/posts?tags=bath"],
          ["blush", "https://e621.net/posts?tags=blush"],
          ["bubble", "https://e621.net/posts?tags=bubble"],
          ["daww", "https://e621.net/posts?tags=daww"],
          ["disembodied_hand", "https://e621.net/posts?tags=disembodied_hand"],
          ["duo", "https://e621.net/posts?tags=duo"],
          ["fangs", "https://e621.net/posts?tags=fangs"],
          ["feral", "https://e621.net/posts?tags=feral"],
          ["fur", "https://e621.net/posts?tags=fur"],
          ["grass", "https://e621.net/posts?tags=grass"],
          ["heart_symbol", "https://e621.net/posts?tags=heart_symbol"],
          ["open_mouth", "https://e621.net/posts?tags=open_mouth"],
          ["plant", "https://e621.net/posts?tags=plant"],
          ["red_blush", "https://e621.net/posts?tags=red_blush"],
          ["soap", "https://e621.net/posts?tags=soap"],
          ["solo_focus", "https://e621.net/posts?tags=solo_focus"],
          ["suds", "https://e621.net/posts?tags=suds"],
          ["teeth", "https://e621.net/posts?tags=teeth"],
          ["uvula", "https://e621.net/posts?tags=uvula"],
          ["dagasi", "https://e621.net/posts?tags=dagasi"],
          ["nintendo", "https://e621.net/posts?tags=nintendo"],
          ["pokemon", "https://e621.net/posts?tags=pokemon"],
          ["generation_9_pokemon", "https://e621.net/posts?tags=generation_9_pokemon"],
          ["pokemon_(species)", "https://e621.net/posts?tags=pokemon_(species)"],
          ["sprigatito", "https://e621.net/posts?tags=sprigatito"],
          ["2022", "https://e621.net/posts?tags=2022"],
          ["digital_media_(artwork)", "https://e621.net/posts?tags=digital_media_(artwork)"],
          ["hi_res", "https://e621.net/posts?tags=hi_res"],
          ["rating:s", "https://e621.net/posts?tags=rating:s"],
        ],
        dtext_artist_commentary_title: "とても良い子に育ちました",
        dtext_artist_commentary_desc: ""
      )
    end

    context "A sample URL" do
      strategy_should_work(
        "https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg",
        image_urls: %w[https://static1.e621.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png],
        media_files: [{ file_size: 1_563_179 }],
        page_url: "https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a",
      )
    end

    context "A self-uploaded post with external source" do
      strategy_should_work(
        "https://e621.net/posts/4835259",
        image_urls: %w[https://static1.e621.net/data/9e/be/9ebe277e202ef0a8e275fe0598c0527d.png],
        media_files: [{ file_size: 1_786_869 }],
        page_url: "https://e621.net/posts/4835259",
        profile_urls: %w[https://e621.net/users/205980 https://inkbunny.net/DAGASI https://www.pixiv.net/users/1549213 https://fantia.jp/fanclubs/34875 https://www.furaffinity.net/user/dagasl https://dagasi.fanbox.cc https://twitter.com/DAGASl2 https://twitter.com/DAGASl https://www.pixiv.net/stacc/daga2626],
        display_name: "DAGASI",
        username: "daga2626",
        dtext_artist_commentary_title: "ロボを狂わせる度し難いニオイ",
        dtext_artist_commentary_desc: <<~EOS.chomp
          その後
          FANBOX【<https://dagasi.fanbox.cc/posts/8017927>】
          fantia【<https://fantia.jp/posts/2785563>】
        EOS
      )
    end

    context "A sourceless self-uploaded post" do
      strategy_should_work(
        "https://e621.net/posts/3599343",
        image_urls: %w[https://static1.e621.net/data/53/98/53983ea953512a86c81d6fdb5f9b1df1.png],
        media_files: [{ file_size: 3_058_658 }],
        page_url: "https://e621.net/posts/3599343",
        profile_urls: %w[https://e621.net/users/366015 https://twitter.com/bnbigus https://www.patreon.com/Bnbigus https://www.furaffinity.net/user/bnbigus https://bnbigus.tumblr.com https://bnbigus.newgrounds.com https://discord.com/invite/8kpwCUm],
        display_name: nil,
        username: "bnbigus",
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil
      )
    end

    context "A sourceless second-party post" do
      strategy_should_work(
        "https://e621.net/posts/4574233",
        image_urls: %w[https://static1.e621.net/data/6a/96/6a962c7056db60fba0c4ca52d8d5266d.png],
        media_files: [{ file_size: 13_919_143 }],
        page_url: "https://e621.net/posts/4574233",
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        dtext_artist_commentary_title: nil,
        dtext_artist_commentary_desc: nil
      )
    end

    context "A login-blocked post" do
      strategy_should_work(
        "https://e621.net/posts/2816118",
        image_urls: %w[https://static1.e621.net/data/a7/f4/a7f439e253c82433656ad7ce62bc9b64.png],
        media_files: [{ file_size: 5_623_796 }],
        page_url: "https://e621.net/posts/2816118",
        profile_urls: %w[https://baraag.net/@Butterchalk https://baraag.net/web/accounts/387484],
        display_name: "Butterchalk",
        username: "Butterchalk",
        tags: [
          ["4_toes", "https://e621.net/posts?tags=4_toes"],
          ["after_kiss", "https://e621.net/posts?tags=after_kiss"],
          ["anthro", "https://e621.net/posts?tags=anthro"],
          ["anthro_on_anthro", "https://e621.net/posts?tags=anthro_on_anthro"],
          ["anthro_penetrated", "https://e621.net/posts?tags=anthro_penetrated"],
          ["anthro_penetrating", "https://e621.net/posts?tags=anthro_penetrating"],
          ["anthro_penetrating_anthro", "https://e621.net/posts?tags=anthro_penetrating_anthro"],
          ["balls", "https://e621.net/posts?tags=balls"],
          ["bed", "https://e621.net/posts?tags=bed"],
          ["bed_sheet", "https://e621.net/posts?tags=bed_sheet"],
          ["bedding", "https://e621.net/posts?tags=bedding"],
          ["big_penis", "https://e621.net/posts?tags=big_penis"],
          ["blue_eyes", "https://e621.net/posts?tags=blue_eyes"],
          ["blurred_background", "https://e621.net/posts?tags=blurred_background"],
          ["bodily_fluids", "https://e621.net/posts?tags=bodily_fluids"],
          ["breasts", "https://e621.net/posts?tags=breasts"],
          ["brother_cumming_in_sister", "https://e621.net/posts?tags=brother_cumming_in_sister"],
          ["brother_penetrating_sister", "https://e621.net/posts?tags=brother_penetrating_sister"],
          ["child", "https://e621.net/posts?tags=child"],
          ["child_on_child", "https://e621.net/posts?tags=child_on_child"],
          ["claws", "https://e621.net/posts?tags=claws"],
          ["cowgirl_position", "https://e621.net/posts?tags=cowgirl_position"],
          ["crouching_cowgirl", "https://e621.net/posts?tags=crouching_cowgirl"],
          ["cum", "https://e621.net/posts?tags=cum"],
          ["cum_in_pussy", "https://e621.net/posts?tags=cum_in_pussy"],
          ["cum_inside", "https://e621.net/posts?tags=cum_inside"],
          ["cum_on_body", "https://e621.net/posts?tags=cum_on_body"],
          ["curtains", "https://e621.net/posts?tags=curtains"],
          ["dominant", "https://e621.net/posts?tags=dominant"],
          ["dominant_female", "https://e621.net/posts?tags=dominant_female"],
          ["duo", "https://e621.net/posts?tags=duo"],
          ["erection", "https://e621.net/posts?tags=erection"],
          ["excessive_cum", "https://e621.net/posts?tags=excessive_cum"],
          ["excessive_genital_fluids", "https://e621.net/posts?tags=excessive_genital_fluids"],
          ["eye_contact", "https://e621.net/posts?tags=eye_contact"],
          ["feet", "https://e621.net/posts?tags=feet"],
          ["female", "https://e621.net/posts?tags=female"],
          ["female_on_top", "https://e621.net/posts?tags=female_on_top"],
          ["female_penetrated", "https://e621.net/posts?tags=female_penetrated"],
          ["flat_chested", "https://e621.net/posts?tags=flat_chested"],
          ["fluffy", "https://e621.net/posts?tags=fluffy"],
          ["fluffy_tail", "https://e621.net/posts?tags=fluffy_tail"],
          ["from_front_position", "https://e621.net/posts?tags=from_front_position"],
          ["fur", "https://e621.net/posts?tags=fur"],
          ["furniture", "https://e621.net/posts?tags=furniture"],
          ["genital_fluids", "https://e621.net/posts?tags=genital_fluids"],
          ["genitals", "https://e621.net/posts?tags=genitals"],
          ["hair", "https://e621.net/posts?tags=hair"],
          ["hand_holding", "https://e621.net/posts?tags=hand_holding"],
          ["inner_ear_fluff", "https://e621.net/posts?tags=inner_ear_fluff"],
          ["interlocked_fingers", "https://e621.net/posts?tags=interlocked_fingers"],
          ["intraspecies", "https://e621.net/posts?tags=intraspecies"],
          ["loli", "https://e621.net/posts?tags=loli"],
          ["long_hair", "https://e621.net/posts?tags=long_hair"],
          ["looking_at_another", "https://e621.net/posts?tags=looking_at_another"],
          ["looking_at_partner", "https://e621.net/posts?tags=looking_at_partner"],
          ["looking_pleasured", "https://e621.net/posts?tags=looking_pleasured"],
          ["lying", "https://e621.net/posts?tags=lying"],
          ["lying_on_bed", "https://e621.net/posts?tags=lying_on_bed"],
          ["male", "https://e621.net/posts?tags=male"],
          ["male/female", "https://e621.net/posts?tags=male%2Ffemale"],
          ["male_on_bottom", "https://e621.net/posts?tags=male_on_bottom"],
          ["male_penetrating", "https://e621.net/posts?tags=male_penetrating"],
          ["male_penetrating_female", "https://e621.net/posts?tags=male_penetrating_female"],
          ["milking_cum", "https://e621.net/posts?tags=milking_cum"],
          ["narrowed_eyes", "https://e621.net/posts?tags=narrowed_eyes"],
          ["nipples", "https://e621.net/posts?tags=nipples"],
          ["nude", "https://e621.net/posts?tags=nude"],
          ["nude_female", "https://e621.net/posts?tags=nude_female"],
          ["on_back", "https://e621.net/posts?tags=on_back"],
          ["on_bed", "https://e621.net/posts?tags=on_bed"],
          ["on_bottom", "https://e621.net/posts?tags=on_bottom"],
          ["on_heels", "https://e621.net/posts?tags=on_heels"],
          ["on_top", "https://e621.net/posts?tags=on_top"],
          ["orgasm", "https://e621.net/posts?tags=orgasm"],
          ["passionate", "https://e621.net/posts?tags=passionate"],
          ["penetration", "https://e621.net/posts?tags=penetration"],
          ["penile", "https://e621.net/posts?tags=penile"],
          ["penile_penetration", "https://e621.net/posts?tags=penile_penetration"],
          ["penis", "https://e621.net/posts?tags=penis"],
          ["penis_in_pussy", "https://e621.net/posts?tags=penis_in_pussy"],
          ["plant", "https://e621.net/posts?tags=plant"],
          ["pupils", "https://e621.net/posts?tags=pupils"],
          ["pussy", "https://e621.net/posts?tags=pussy"],
          ["saliva", "https://e621.net/posts?tags=saliva"],
          ["saliva_on_tongue", "https://e621.net/posts?tags=saliva_on_tongue"],
          ["saliva_string", "https://e621.net/posts?tags=saliva_string"],
          ["seductive", "https://e621.net/posts?tags=seductive"],
          ["sex", "https://e621.net/posts?tags=sex"],
          ["shota", "https://e621.net/posts?tags=shota"],
          ["size_difference", "https://e621.net/posts?tags=size_difference"],
          ["slit_pupils", "https://e621.net/posts?tags=slit_pupils"],
          ["small_breasts", "https://e621.net/posts?tags=small_breasts"],
          ["small_but_hung", "https://e621.net/posts?tags=small_but_hung"],
          ["smaller_penetrated", "https://e621.net/posts?tags=smaller_penetrated"],
          ["squatting_position", "https://e621.net/posts?tags=squatting_position"],
          ["striped_body", "https://e621.net/posts?tags=striped_body"],
          ["striped_fur", "https://e621.net/posts?tags=striped_fur"],
          ["stripes", "https://e621.net/posts?tags=stripes"],
          ["tail", "https://e621.net/posts?tags=tail"],
          ["thick_penis", "https://e621.net/posts?tags=thick_penis"],
          ["toes", "https://e621.net/posts?tags=toes"],
          ["tuft", "https://e621.net/posts?tags=tuft"],
          ["vaginal", "https://e621.net/posts?tags=vaginal"],
          ["vaginal_penetration", "https://e621.net/posts?tags=vaginal_penetration"],
          ["vein", "https://e621.net/posts?tags=vein"],
          ["veiny_penis", "https://e621.net/posts?tags=veiny_penis"],
          ["white_hair", "https://e621.net/posts?tags=white_hair"],
          ["yellow_eyes", "https://e621.net/posts?tags=yellow_eyes"],
          ["young", "https://e621.net/posts?tags=young"],
          ["young_anthro", "https://e621.net/posts?tags=young_anthro"],
          ["young_female", "https://e621.net/posts?tags=young_female"],
          ["young_male", "https://e621.net/posts?tags=young_male"],
          ["young_on_young", "https://e621.net/posts?tags=young_on_young"],
          ["butterchalk", "https://e621.net/posts?tags=butterchalk"],
          ["amalia_(claralaine)", "https://e621.net/posts?tags=amalia_(claralaine)"],
          ["ken_(claralaine)", "https://e621.net/posts?tags=ken_(claralaine)"],
          ["domestic_cat", "https://e621.net/posts?tags=domestic_cat"],
          ["felid", "https://e621.net/posts?tags=felid"],
          ["feline", "https://e621.net/posts?tags=feline"],
          ["felis", "https://e621.net/posts?tags=felis"],
          ["mammal", "https://e621.net/posts?tags=mammal"],
          ["2021", "https://e621.net/posts?tags=2021"],
          ["hi_res", "https://e621.net/posts?tags=hi_res"],
          ["brother_(lore)", "https://e621.net/posts?tags=brother_(lore)"],
          ["brother_and_sister_(lore)", "https://e621.net/posts?tags=brother_and_sister_(lore)"],
          ["incest_(lore)", "https://e621.net/posts?tags=incest_(lore)"],
          ["pseudo_incest_(lore)", "https://e621.net/posts?tags=pseudo_incest_(lore)"],
          ["sibling_(lore)", "https://e621.net/posts?tags=sibling_(lore)"],
          ["sister_(lore)", "https://e621.net/posts?tags=sister_(lore)"],
          ["rating:e", "https://e621.net/posts?tags=rating:e"],
        ],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: "more"
      )
    end

    should "Parse e621 URLs correctly" do
      assert(Source::URL.image_url?("https://static1.e621.net/data/sample/ae/ae/aeaed0dfba6468ec992c6e5cc46763c1_720p.mp4"))
      assert(Source::URL.image_url?("https://static1.e926.net/data/preview/6d/1a/6d1a6090ea82c2524212499797e7e53a.jpg"))
      assert(Source::URL.image_url?("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png"))

      assert_equal("https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a", Source::URL.page_url("https://static1.e926.net/data/6d/1a/6d1a6090ea82c2524212499797e7e53a.png"))

      assert(Source::URL.page_url?("https://e621.net/posts?md5=6d1a6090ea82c2524212499797e7e53a"))
      assert(Source::URL.page_url?("https://e621.net/posts/3728701"))
      assert(Source::URL.page_url?("https://e926.net/posts/3728701"))

      assert(Source::URL.profile_url?("https://e621.net/users/205980"))
    end
  end
end
