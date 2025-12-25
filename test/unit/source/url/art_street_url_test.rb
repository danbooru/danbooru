require "test_helper"

module Source::Tests::URL
  class ArtStreetUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/1280_960/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png",
          "https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png",
          "https://dqmk835cy5zzx.cloudfront.net/f7/current/f72107281839259430002176282/798080e1-1361-49c0-84aa-06518bdf1a22.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kcW1rODM1Y3k1enp4LmNsb3VkZnJvbnQubmV0L2Y3L2N1cnJlbnQvZjcyMTA3MjgxODM5MjU5NDMwMDAyMTc2MjgyLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODAxMTMzNzB9fX1dfQ__&Signature=QG35KafzMXXY1hlsXnJHKnlZYU~hBrduhfh-StKFhudNRLNFbidoeGsF1pnVhyeHJQNdRkRg6WwErw-q35HIZLxoC5ugWY64tdnY-l6H1rI-M2mSIiMkYEDUP6mqBXCgObZaCV6Lk6b18s~trzbXbYO9cMVDvJ5DSvMJb1f1G~pDBbSsgulVRNUppQcPqjM3ObvRqsRtEMxwjuafEJ33JmfVTr-hUzk-ncTL-MegEiC7qFaT0o08cHKXO4385JBUt8S6ZcNch-EvNbEXIxUsK-XH-VeAy93cuJ~Ez0VioZarwlFejXH0K--b2lzwwroqGfke4gVFH0I4Skc4GVnF9g__&Key-Pair-Id=APKAI322DZTKDWD5CY2Q",

        ],
        profile_urls: [
          "https://medibang.com/author/8769655",
          "https://medibang.com/author/749476/gallery/?cat=illust",
          "https://medibang.com/u/16672238/",
          "https://medibang.com/u/16672238/gallery/?cat=comic",
          "https://medibang.com/u/littlegfu3/",
        ],
        page_urls: [
          "https://medibang.com/picture/4b2112261505098280008769655/",
          "https://medibang.com/book/f72107281839259430002176282/",
          "https://medibang.com/viewer/f72107281839259430002176282/",
        ],
      )
    end
  end
end
