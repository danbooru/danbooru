require "test_helper"

module Source::Tests::URL
  class SkebUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://skeb.imgix.net/requests/229088_2?bg=%23fff&auto=format&w=800&s=9cac8b76c0838f2df4f19ebc41c1ae0a",
          "https://skeb.imgix.net/uploads/origins/04d62c2f-e396-46f9-903a-3ca8bd69fc7c?bg=%23fff&auto=format&w=800&s=966c5d0389c3b94dc36ac970f812bef4",
          "https://skeb-production.s3.ap-northeast-1.amazonaws.com/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=attachment%3B%20filename%3D%22458093-1.output.mp4%22%3B%20filename%2A%3DUTF-8%27%27458093-1.output.mp4&response-content-type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVPUTFQBBL7UDSUA%2F20220221%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220221T200057Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7f028cfd9a56344cf1d42410063fad3ef30a1e47b83cef047247e0c37df01df0",
          "https://fcdn.skeb.jp/uploads/outputs/734e0c33-878c-4a83-bbf8-6212be31abbe?response-content-disposition=inline&Expires=1676373664&Signature=MpNqM4OiJIdkdG0o7q~22bmEA39FFhi4XXRQp5jb3RC0JxH5w6uDd6vJ552v08JGafajn-BaHYnMBg3kH86xUM8w5ySzqYB9fqHbdeIu2iiTtttQif6IdQEJnBPYrH56KXsFMftkf1nn18~GX~HSount0wnYPfPZ7bts7AepbeqOmPEspfnFMkJfemVWGCFKK-cIW1jfi2ZiAEOeSSBqxGDBJhD0LP9eJEZMJkk3ZTeFMJcTFHFXfa35wEzaZP7c6pFNKeIC8SVa2zqER46HrGPsAW316kVgfzFCP9vQ~XgZevjGJRC9BBhHLpuOKEZR-QG1ucQvPQg38cVP5DhwcQ__&Key-Pair-Id=K1GS3H53SEO647",
          "https://cdn.skeb.jp/uploads/outputs/734e0c33-878c-4a83-bbf8-6212be31abbe?response-content-disposition=inline&Expires=1676373664&Signature=MpNqM4OiJIdkdG0o7q~22bmEA39FFhi4XXRQp5jb3RC0JxH5w6uDd6vJ552v08JGafajn-BaHYnMBg3kH86xUM8w5ySzqYB9fqHbdeIu2iiTtttQif6IdQEJnBPYrH56KXsFMftkf1nn18~GX~HSount0wnYPfPZ7bts7AepbeqOmPEspfnFMkJfemVWGCFKK-cIW1jfi2ZiAEOeSSBqxGDBJhD0LP9eJEZMJkk3ZTeFMJcTFHFXfa35wEzaZP7c6pFNKeIC8SVa2zqER46HrGPsAW316kVgfzFCP9vQ~XgZevjGJRC9BBhHLpuOKEZR-QG1ucQvPQg38cVP5DhwcQ__&Key-Pair-Id=K1GS3H53SEO647",
        ],
        page_urls: [
          "https://skeb.jp/@OrvMZ/works/3",
          "https://skeb.jp/works/133404",
        ],
        profile_urls: [
          "https://skeb.jp/@asanagi",
          "https://www.skeb.jp/@asanagi",
          "https://skeb.jp/asanagi",
        ],
      )
    end
  end
end
