require "test_helper"

module Source::Tests::URL
  class MihuashiUrlTest < ActiveSupport::TestCase
    context "Mihuashi URLs" do
      should be_image_url(
        "https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg",
        "https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png",
        "https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg!artwork.detail",
        "https://image-assets.mihuashi.com/permanent/5716548|-2025/07/11/20/lrItT-MRSxSjnXvyD5CNze8JucPI_2129.png!mobile.square.large",
        "https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg!sq300.2x",
        "https://image-assets.mihuashi.com/pfop/permanent/4329541|-2024/07/12/18/Fu2oKtHkplA-waTASBzUpF6EozkB.jpg",
        "https://image-assets.mihuashi.com/44571|-2021/09/16/18/FvNAijlnNYfJtaVQdZNoDYHj9mPP.png!artwork.detail",
        "https://image-assets.mihuashi.com/2016/12/08/13/gx77j3j5vdtseg9xqmmgovzxj4yhtwpm/红白_.jpg",
        "https://activity-assets.mihuashi.com/2019/05/03/09/yh2td3fkw381mtsjtn4p7ob1iyc2s25r/yh2td3fkw381mtsjtn4p7ob1iyc2s25r.png",
      )

      should be_page_url(
        "https://www.mihuashi.com/artworks/15092919",
        "https://www.mihuashi.com/stalls/880743",
        "https://www.mihuashi.com/projects/6380467",
        "https://www.mihuashi.com/character-card/13373e0997be5d906df9ce292da8ddf6552a340a",
        "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c/project",
        "https://www.mihuashi.com/activities/houkai3-stigmata/artworks/8523",
        "https://www.mihuashi.com/activities/jw3-exterior-12/artworks/10515?type=zjjh",
      )

      should be_profile_url(
        "https://www.mihuashi.com/profiles/29105",
        "https://www.mihuashi.com/profiles/29105?role=painter",
        "https://www.mihuashi.com/users/spirtie",
      )

      should be_secondary_url(
        "https://www.mihuashi.com/users/spirtie",
      )

      should_not be_secondary_url(
        "https://www.mihuashi.com/profiles/29105",
      )

      context "when extracting attributes" do
        should parse_url("https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c/project").into(
          page_url: "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c",
        )
        should parse_url("https://www.mihuashi.com/activities/houkai3-stigmata/artworks/8523").into(
          page_url: "https://www.mihuashi.com/activities/houkai3-stigmata/artworks/8523",
        )
        should parse_url("https://www.mihuashi.com/activities/jw3-exterior-12/artworks/10515?type=zjjh").into(
          page_url: "https://www.mihuashi.com/activities/jw3-exterior-12/artworks/10515?type=zjjh",
        )

        should parse_url("https://www.mihuashi.com/profiles/29105?role=painter").into(
          profile_url: "https://www.mihuashi.com/profiles/29105",
        )

        should parse_url("https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg").into(
          full_image_url: "https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg",
          profile_url: "https://www.mihuashi.com/profiles/29105",
        )
        should parse_url("https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png").into(
          full_image_url: "https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png",
        )
        should parse_url("https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg!artwork.detail").into(
          full_image_url: "https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg",
        )
        should parse_url("https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg!sq300.2x").into(
          full_image_url: "https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg",
        )
        should parse_url("https://image-assets.mihuashi.com/pfop/permanent/4329541|-2024/07/12/18/Fu2oKtHkplA-waTASBzUpF6EozkB.jpg").into(
          full_image_url: "https://image-assets.mihuashi.com/permanent/4329541|-2024/07/12/18/Fu2oKtHkplA-waTASBzUpF6EozkB.jpg",
          profile_url: "https://www.mihuashi.com/profiles/4329541",
        )
        should parse_url("https://image-assets.mihuashi.com/44571|-2021/09/16/18/FvNAijlnNYfJtaVQdZNoDYHj9mPP.png").into(
          full_image_url: "https://image-assets.mihuashi.com/44571|-2021/09/16/18/FvNAijlnNYfJtaVQdZNoDYHj9mPP.png",
          profile_url: "https://www.mihuashi.com/profiles/44571",
        )
        should parse_url("https://image-assets.mihuashi.com/2016/12/08/13/gx77j3j5vdtseg9xqmmgovzxj4yhtwpm/红白_.jpg!artwork.detail").into(
          full_image_url: "https://image-assets.mihuashi.com/2016/12/08/13/gx77j3j5vdtseg9xqmmgovzxj4yhtwpm/红白_.jpg",
        )
        should parse_url("https://images.mihuashi.com/2016/06/17/23/thpe8pgsekfzw23ammqnmdmtpdj6me22/Q板天子.png").into(
          full_image_url: "https://image-assets.mihuashi.com/2016/06/17/23/thpe8pgsekfzw23ammqnmdmtpdj6me22/Q板天子.png",
        )
      end
    end
  end
end
