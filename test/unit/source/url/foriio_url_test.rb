require "test_helper"

module Source::Tests::URL
  class ForiioUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg?ixlib=rb-4.1.0&w=2184&auto=compress&s=a9a14e871e2f6dbdc28f87c915e8684f",
          "https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg",
          "https://foriio-og-images.s3.ap-northeast-1.amazonaws.com/407656ab2d5c71a1d3b5745bcce16544",
          "https://foriio-og-thumbs.s3.ap-northeast-1.amazonaws.com/0681cb32dff4d90465e045cca348ace8.jpg",
          "https://dyci7co52mbcc.cloudfront.net/store/8e4827d9abbc957ef333917a15f71d1e.png",
        ],
        page_urls: [
          "https://www.foriio.com/works/600743",
          "https://www.foriio.com/embeded/works/600743",
        ],
        profile_urls: [
          "https://fori.io/comori22",
          "https://www.foriio.com/comori22",
          "https://www.foriio.com/comori22/categories/Illustration",
        ],
      )
    end
  end
end
