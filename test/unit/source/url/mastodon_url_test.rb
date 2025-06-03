require "test_helper"

module Source::Tests::URL
  class MastodonUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png",
          "https://pawoo.net/media/lU2uV7C1MMQSb1czwvg",
          "https://baraag.net/system/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4",
          "https://media.baraag.net/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4",
        ],
        page_urls: [
          "https://pawoo.net/@evazion/19451018",
          "https://pawoo.net/web/statuses/19451018",
          "https://baraag.net/@curator/102270656480174153",
          "https://baraag.net/web/statuses/102270656480174153",
        ],
        profile_urls: [
          "https://pawoo.net/@evazion",
          "https://pawoo.net/users/esoraneko",
          "https://pawoo.net/web/accounts/47806",
          "https://baraag.net/@danbooru",
          "https://baraag.net/@web/danbooru",
          "https://baraag.net/web/accounts/107862785324786980",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://pawoo.net/@evazion/19451018/",
                             page_url: "https://pawoo.net/@evazion/19451018",
                             username: "evazion",
                             work_id: "19451018",)

      url_parser_should_work("https://pawoo.net/web/statuses/19451018/favorites",
                             page_url: "https://pawoo.net/web/statuses/19451018",
                             username: nil,
                             work_id: "19451018",)

      url_parser_should_work("https://baraag.net/@bardbot/105732813175612920/",
                             page_url: "https://baraag.net/@bardbot/105732813175612920",
                             username: "bardbot",
                             work_id: "105732813175612920",)

      url_parser_should_work("https://pawoo.net/@evazion/media", username: "evazion", page_url: nil)
      url_parser_should_work("https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png", page_url: nil)
      url_parser_should_work("https://media.baraag.net/media_attachments/files/105/732/803/241/495/700/original/556e1eb7f5ca610f.png", page_url: nil)
    end
  end
end
