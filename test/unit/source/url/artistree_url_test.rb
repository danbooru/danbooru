require "test_helper"

module Source::Tests::URL
  class ArtistreeUrlTest < ActiveSupport::TestCase
    context "Artistree URLs" do
      should be_image_url(
        "https://dwxo6p939as9l.cloudfront.net/seraexecfia/Anime Illustration/s6-s1lkmz.jpg",
        "https://dwxo6p939as9l.cloudfront.net/alysonsega/Full render (Character and/or Background/Object)/Sonicandmariotransparent-rkdqe1.png",
      )

      should be_profile_url(
        "https://artistree.io/crestfallen163",
        "https://artistree.io/request/adolfozapp",
        "https://artistree.io/queue/adolfozapp",
      )

      should be_page_url(
        "https://artistree.io/crestfallen163",
        "https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1",
      )

      should_not be_profile_url(
        "https://artistree.io/crestfallen163#d2ca3306-0a5d-426e-925a-191593e6cfe1",
      )
    end
  end
end
