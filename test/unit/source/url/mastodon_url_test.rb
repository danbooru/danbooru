require "test_helper"

module Source::Tests::URL
  class MastodonUrlTest < ActiveSupport::TestCase
    context "Mastodon URLs" do
      should be_image_url(
        "https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png",
        "https://pawoo.net/media/lU2uV7C1MMQSb1czwvg",
        "https://baraag.net/system/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4",
        "https://media.baraag.net/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4",
      )

      should be_page_url(
        "https://pawoo.net/@evazion/19451018",
        "https://pawoo.net/web/statuses/19451018",
        "https://baraag.net/@curator/102270656480174153",
        "https://baraag.net/web/statuses/102270656480174153",
      )

      should be_profile_url(
        "https://pawoo.net/@evazion",
        "https://pawoo.net/users/esoraneko",
        "https://pawoo.net/web/accounts/47806",
        "https://baraag.net/@danbooru",
        "https://baraag.net/@web/danbooru",
        "https://baraag.net/web/accounts/107862785324786980",
      )

      should parse_url("https://pawoo.net/@evazion/19451018/").into(
        page_url: "https://pawoo.net/@evazion/19451018",
        username: "evazion",
        work_id: "19451018",
      )

      should parse_url("https://pawoo.net/web/statuses/19451018/favorites").into(
        page_url: "https://pawoo.net/web/statuses/19451018",
        username: nil,
        work_id: "19451018",
      )

      should parse_url("https://baraag.net/@bardbot/105732813175612920/").into(
        page_url: "https://baraag.net/@bardbot/105732813175612920",
        username: "bardbot",
        work_id: "105732813175612920",
      )

      should parse_url("https://pawoo.net/@evazion/media").into(username: "evazion", page_url: nil)
      should parse_url("https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png").into(page_url: nil)
      should parse_url("https://media.baraag.net/media_attachments/files/105/732/803/241/495/700/original/556e1eb7f5ca610f.png").into(page_url: nil)
    end
  end
end
