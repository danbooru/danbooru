require "test_helper"

module Source::Tests::URL
  class BehanceUrlTest < ActiveSupport::TestCase
    context "Behance URLs" do
      should be_image_url(
        "https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg",
        "https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg",
        "https://mir-s3-cdn-cf.behance.net/projects/404/9d2bad97612065.Y3JvcCwxMjAwLDkzOCwyODUsMzU.jpg",
        "https://mir-cdn.behance.net/v1/rendition/project_modules/1400/828dc625691931.5634a721e19dd.jpg",
      )

      should be_page_url(
        "https://www.behance.net/gallery/97612065/SailorMoon",
        "https://www.behance.net/gallery/97612065/SailorMoon/modules/563634913",
      )

      should be_profile_url(
        "https://www.behance.net/Kensukecreations",
        "https://www.behance.net/Kensukecreations/projects",
      )

      should parse_url("https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg").into(
        page_url: "https://www.behance.net/gallery/97612065/Title",
      )
    end

    should parse_url("https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg").into(site_name: "Behance")
  end
end
