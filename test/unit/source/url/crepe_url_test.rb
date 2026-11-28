require "test_helper"

module Source::Tests::URL
  class CrepeUrlTest < ActiveSupport::TestCase
    context "Crepe URLs" do
      should be_image_url(
        "https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png",
        "https://crepe.land/portfolio/6/6h/6hwx89nokxxdag7n24ee1yfhndsu0nan_%EB%82%99%EC%84%AF%21.jpg",
        "https://crepe.land/user_profile/c/cp/cpvwzgjo74j6h1v95thpti6rfq71ifg4_image.jpg",
        "https://crepe.land/static/user_profile/default_profile_image.png",
        "https://i.crepe.land/https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png?h=640&q=100&t=i&v=3a&w=1280",
        "https://i.crepe.land/https://crepe.land/user_profile/c/cp/cpvwzgjo74j6h1v95thpti6rfq71ifg4_image.jpg?h=128&q=100&t=i&v=3a&w=128&x=2",
      )

      should be_image_sample(
        "https://i.crepe.land/https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png?h=640&q=100&t=i&v=3a&w=1280",
      )

      should_not be_image_sample(
        "https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png",
      )

      should be_page_url(
        "https://crepe.cm/@yolrsona/t71oz0uls",
        "https://crepe.cm/ko/@yolrsona/t71oz0uls",
        "https://crepe.cm/en/@yolrsona/t71oz0uls",
        "https://crepe.cm/@yolrsona/t71oz0uls/edit",
        "https://crepe.cm/@yolrsona/portfolios/abc123",
        "https://crepe.cm/ko/@yolrsona/portfolios/abc123",
        "https://crepe.cm/@yolrsona/portfolios/abc123/edit",
      )

      should be_profile_url(
        "https://crepe.cm/@yolrsona",
        "https://crepe.cm/ko/@yolrsona",
        "https://crepe.cm/@yolrsona/portfolios",
      )

      should_not be_page_url(
        "https://kre.pe/E0f0",
      )

      should parse_url("https://crepe.cm/ko/@yolrsona/t71oz0uls").into(
        site_name: "Crepe",
        username: "yolrsona",
        commission_slug: "t71oz0uls",
        portfolio_slug: nil,
        page_url: "https://crepe.cm/@yolrsona/t71oz0uls",
        profile_url: "https://crepe.cm/@yolrsona",
      )

      should parse_url("https://crepe.cm/@yolrsona/t71oz0uls/edit").into(
        page_url: "https://crepe.cm/@yolrsona/t71oz0uls",
      )

      should parse_url("https://crepe.cm/ko/@yolrsona/portfolios/abc123/edit").into(
        username: "yolrsona",
        commission_slug: nil,
        portfolio_slug: "abc123",
        page_url: "https://crepe.cm/@yolrsona/portfolios/abc123",
        profile_url: "https://crepe.cm/@yolrsona",
      )

      should parse_url("https://crepe.cm/@Lively_kli/portfolios").into(
        username: "Lively_kli",
        page_url: nil,
        profile_url: "https://crepe.cm/@Lively_kli",
      )

      should parse_url("https://crepe.cm/@Lively_kli").into(
        username: "Lively_kli",
        page_url: nil,
        profile_url: "https://crepe.cm/@Lively_kli",
      )

      should parse_url("https://kre.pe/E0f0").into(
        site_name: "Crepe",
        redirect_id: "E0f0",
        page_url: nil,
        profile_url: nil,
      )

      should parse_url("https://i.crepe.land/https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png?h=640&q=100&t=i&v=3a&w=1280").into(
        site_name: "Crepe",
        full_image_url: "https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png",
        page_url: nil,
        profile_url: nil,
      )

      should parse_url("https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png").into(
        full_image_url: "https://crepe.land/commission_type/v/vf/vff9q0hf43mcib0nq3cyf4whpzv02ajv_%E3%85%8E%E3%85%87%E3%84%B4.png",
      )

      should parse_url("https://crepe.cm").into(username: nil, page_url: nil, profile_url: nil)
      should parse_url("https://crepe.cm/ko/search?query=%23SD").into(username: nil, page_url: nil, profile_url: nil)
      should parse_url("https://crepe.cm/@yolrsona/t71oz0uls/reviews").into(username: nil, page_url: nil, profile_url: nil)
      should parse_url("https://help.crepe.cm/hc/ko").into(username: nil, page_url: nil, profile_url: nil)

      should parse_url("https://crepe.cm/@yolrsona/..%2F..%2Fgraphql%3Fx=1").into(commission_slug: nil, page_url: nil)
      should parse_url("https://crepe.cm/@yolrsona/t71oz0uls%3Fx=1").into(commission_slug: nil, page_url: nil)
      should parse_url("https://crepe.cm/@yolrsona/portfolios/..%2F..%2Fadmin").into(portfolio_slug: nil, page_url: nil)
      should parse_url("https://kre.pe/..%2Fx").into(redirect_id: nil)
    end
  end
end
