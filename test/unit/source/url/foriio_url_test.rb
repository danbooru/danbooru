require "test_helper"

module Source::Tests::URL
  class ForiioUrlTest < ActiveSupport::TestCase
    context "Foriio URLs" do
      should be_image_url(
        "https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg?ixlib=rb-4.1.0&w=2184&auto=compress&s=a9a14e871e2f6dbdc28f87c915e8684f",
        "https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg",
        "https://foriio-og-images.s3.ap-northeast-1.amazonaws.com/407656ab2d5c71a1d3b5745bcce16544",
        "https://foriio-og-thumbs.s3.ap-northeast-1.amazonaws.com/0681cb32dff4d90465e045cca348ace8.jpg",
        "https://dyci7co52mbcc.cloudfront.net/store/8e4827d9abbc957ef333917a15f71d1e.png",
        "https://img.foriio.com/images/r/im_AT9deWzUD-NWfS8237_Cm4JuoWaq9gc-xQnT7-cTcDS_WJ5xqb4?w=1092",
        "https://img.foriio.com/images/store/387d11df83ebbb2301041a7f88630bbf.jpg",
      )

      should be_page_url(
        "https://www.foriio.com/works/600743",
        "https://www.foriio.com/embeded/works/600743",
      )

      should be_profile_url(
        "https://fori.io/comori22",
        "https://www.foriio.com/comori22",
        "https://www.foriio.com/comori22/categories/Illustration",
      )
    end

    should parse_url("https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg?ixlib=rb-4.1.0&w=2184&auto=compress&s=a9a14e871e2f6dbdc28f87c915e8684f").into(site_name: "Foriio")

    should parse_url("https://img.foriio.com/images/r/im_AT9deWzUD-NWfS8237_Cm4JuoWaq9gc-xQnT7-cTcDS_WJ5xqb4?w=1092").into(
      full_image_url: "https://img.foriio.com/images/r/im_AT9deWzUD-NWfS8237_Cm4JuoWaq9gc-xQnT7-cTcDS_WJ5xqb4?w=10000&fit=max",
    )

    should parse_url("https://img.foriio.com/images/store/387d11df83ebbb2301041a7f88630bbf.jpg?auto=compress&fit=crop&h=424&w=688").into(
      full_image_url: "https://img.foriio.com/images/store/387d11df83ebbb2301041a7f88630bbf.jpg",
    )
  end
end
