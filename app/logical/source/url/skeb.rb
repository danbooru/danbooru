# frozen_string_literal: true

class Source::URL::Skeb < Source::URL
  RESERVED_USERNAMES = %w[works users about terms creator client company]

  attr_reader :username, :illust_id, :work_id, :image_id, :image_uuid

  def self.match?(url)
    url.host.in?(%w[www.skeb.jp fcdn.skeb.jp cdn.skeb.jp skeb.jp skeb.imgix.net si.imgix.net skeb-production.s3.ap-northeast-1.amazonaws.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://skeb.jp/@OrvMZ/works/3 (non-watermarked)
    # https://skeb.jp/@OrvMZ/works/1 (separated request and client's message after delivery)
    # https://skeb.jp/@asanagi/works/16 (age-restricted, watermarked)
    # https://skeb.jp/@asanagi/works/6 (private, returns 404)
    # https://skeb.jp/@nasuno42/works/30 (multi-image post)
    in _, "skeb.jp", /^@/ => username, "works", illust_id
      @username = username.delete_prefix("@")
      @illust_id = illust_id

    # https://skeb.jp/works/133404
    in _, "skeb.jp", "works", work_id
      @work_id = work_id

    # https://skeb.jp/@asanagi
    # https://skeb.jp/@okku_oxn/works
    in _, "skeb.jp", /^@/ => username, *rest
      @username = username.delete_prefix("@")

    # https://skeb.jp/OrvMZ
    in "www" | nil, "skeb.jp", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://skeb.imgix.net/requests/199886_0?bg=%23fff&auto=format&w=800&s=5a6a908ab964fcdfc4713fad179fe715
    # https://skeb.imgix.net/requests/73290_0?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&w=800&s=4843435cff85d623b1f657209d131526
    # https://skeb.imgix.net/requests/53269_1?bg=%23fff&fm=png&dl=53269.png&w=1.0&h=1.0&s=44588ea9c41881049e392adb1df21cce (full size)
    in "skeb", "imgix.net", "requests", image_id
      @image_id = image_id

    # https://skeb.imgix.net/uploads/origins/04d62c2f-e396-46f9-903a-3ca8bd69fc7c?bg=%23fff&auto=format&w=800&s=966c5d0389c3b94dc36ac970f812bef4
    in "skeb", "imgix.net", "uploads", "origins", /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/ => image_uuid
      @image_uuid = image_uuid

    # https://si.imgix.net/17e73ecf/uploads/origins/5097b1e1-18ce-418e-82f0-e7e2cdab1cea?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=701f0e4a2c63865fe7e295b6c66b543b
    in "si", "imgix.net", /^\h{8}$/, "uploads", "origins", /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/ => image_uuid
      @image_uuid = image_uuid

    # https://si.imgix.net/a5dd8523/requests/191942_0?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=webp&w=800&s=80e19a49375f63973ffe3674553a230c
    in "si", "imgix.net", /^\h{8}$/, "requests", image_id
      @image_id = image_id

    # Page: https://skeb.jp/@kaisouafuro/works/112
    # https://skeb-production.s3.ap-northeast-1.amazonaws.com/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=attachment%3B%20filename%3D%22458093-1.output.mp4%22%3B%20filename%2A%3DUTF-8%27%27458093-1.output.mp4&response-content-type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVPUTFQBBL7UDSUA%2F20220221%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220221T200057Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7f028cfd9a56344cf1d42410063fad3ef30a1e47b83cef047247e0c37df01df0
    # https://fcdn.skeb.jp/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=inline&Expires=1676373664&Signature=BNFCR248Xkvk4E8Th-a1~zopTL1NvP9rhu78n7YSSPt9K2PGM5GgmLLiXltj~5FteosdONepKLVeENVxTFBXRj~FgOGYQV7AehfBF2eMYB6V3v9at1cxFsqOFXjiPHohmqRzvzKHlVe-GlA6U4~ClYKsw0Ur9QSIlZ79iJlsTIbz~wzIzp463h~8KuAi81oBSLvdOJkm1qpEY2Em0PjUtNfx36Gk5jjCPRq5oVvITkdc~VrLLR~GNPjWAedkEhct~aVMAU56PQH6Few0LNoqjmCJZeY2d8mz0lugICGq2S9JPMmPQVR7HOFD0x3JBpX3-WWSmhC3F8f8lkErVNAv~A__&Key-Pair-Id=K1GS3H53SEO647
    # https://cdn.skeb.jp/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=inline&Expires=1676373664&Signature=BNFCR248Xkvk4E8Th-a1~zopTL1NvP9rhu78n7YSSPt9K2PGM5GgmLLiXltj~5FteosdONepKLVeENVxTFBXRj~FgOGYQV7AehfBF2eMYB6V3v9at1cxFsqOFXjiPHohmqRzvzKHlVe-GlA6U4~ClYKsw0Ur9QSIlZ79iJlsTIbz~wzIzp463h~8KuAi81oBSLvdOJkm1qpEY2Em0PjUtNfx36Gk5jjCPRq5oVvITkdc~VrLLR~GNPjWAedkEhct~aVMAU56PQH6Few0LNoqjmCJZeY2d8mz0lugICGq2S9JPMmPQVR7HOFD0x3JBpX3-WWSmhC3F8f8lkErVNAv~A__&Key-Pair-Id=K1GS3H53SEO647
    in _, ("skeb.jp" | "amazonaws.com"), "uploads", "outputs", /^\h{8}-\h{4}-\h{4}-\h{4}-\h{12}$/ => image_uuid
      @image_uuid = image_uuid

    else
      nil
    end
  end

  def page_url
    if username.present? && illust_id.present?
      "https://skeb.jp/@#{username}/works/#{illust_id}"
    elsif work_id.present?
      "https://skeb.jp/works/#{work_id}"
    end
  end

  def api_url
    if username.present? && illust_id.present?
      "https://skeb.jp/api/users/#{username}/works/#{illust_id}"
    elsif work_id.present?
      "https://skeb.jp/api/works/#{work_id}"
    end
  end

  def profile_url
    "https://skeb.jp/@#{username}" if username.present?
  end

  def image_url?
    image_id.present? || image_uuid.present?
  end

  def animated?
    image_url? && params[:fm].in?(["gif", "mp4"])
  end

  def watermarked?
    image_url? && params[:txt].present?
  end
end
