require "test_helper"

module Source::Tests::URL
  class BehanceUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg",
          "https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg",
          "https://mir-s3-cdn-cf.behance.net/projects/404/9d2bad97612065.Y3JvcCwxMjAwLDkzOCwyODUsMzU.jpg",
          "https://mir-cdn.behance.net/v1/rendition/project_modules/1400/828dc625691931.5634a721e19dd.jpg",
        ],
        page_urls: [
          "https://www.behance.net/gallery/97612065/SailorMoon",
          "https://www.behance.net/gallery/97612065/SailorMoon/modules/563634913",
        ],
        profile_urls: [
          "https://www.behance.net/Kensukecreations",
          "https://www.behance.net/Kensukecreations/projects",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work(
        "https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg",
        page_url: "https://www.behance.net/gallery/97612065/Title",
      )
    end
  end
end
