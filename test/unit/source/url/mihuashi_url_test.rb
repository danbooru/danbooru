require "test_helper"

module Source::Tests::URL
  class MihuashiUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg",
          "https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png",
          "https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg!artwork.detail",
          "https://image-assets.mihuashi.com/permanent/5716548|-2025/07/11/20/lrItT-MRSxSjnXvyD5CNze8JucPI_2129.png!mobile.square.large",
          "https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg!sq300.2x",
        ],
        page_urls: [
          "https://www.mihuashi.com/artworks/15092919",
          "https://www.mihuashi.com/stalls/880743",
          "https://www.mihuashi.com/projects/6380467",
          "https://www.mihuashi.com/character-card/13373e0997be5d906df9ce292da8ddf6552a340a",
          "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c/project",
        ],
        profile_urls: [
          "https://www.mihuashi.com/profiles/29105",
          "https://www.mihuashi.com/profiles/29105?role=painter",
          "https://www.mihuashi.com/users/spirtie",
        ],
      )

      context "when extracting attributes" do
        url_parser_should_work(
          "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c/project",
          page_url: "https://www.mihuashi.com/character-card/4dc65278776db4741a897d7445f48a6b57ce251c",
        )

        url_parser_should_work(
          "https://www.mihuashi.com/profiles/29105",
          profile_url: "https://www.mihuashi.com/profiles/29105?role=painter",
        )

        url_parser_should_work(
          "https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg",
          full_image_url: "https://image-assets.mihuashi.com/permanent/29105|-2024/05/29/16/FuE-9jWo-aPKXOq2KP2ZsR5Nxnqa.jpg",
        )
        url_parser_should_work(
          "https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png",
          full_image_url: "https://image-assets.mihuashi.com/permanent/2521440|-2025/07/12/18/lmmkwWRHf4RwLdm3mRanVRNUk2Oy_1123.png",
        )
        url_parser_should_work(
          "https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg!artwork.detail",
          full_image_url: "https://image-assets.mihuashi.com/permanent/29105|-2025/05/30/15/Flz917NRVbHcZeG9xW1KklVM_s3y_1046.jpg",
        )
        url_parser_should_work(
          "https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg!sq300.2x",
          full_image_url: "https://image-assets.mihuashi.com/permanent/3684329|-2025/05/18/12/Fk7FRRsUA6QW80rthbEJULPuA5nQ_5546.jpg",
        )
      end
    end
  end
end
