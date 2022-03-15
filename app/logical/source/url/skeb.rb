# frozen_string_literal: true

class Source::URL::Skeb < Source::URL
  attr_reader :username, :work_id, :image_id, :image_uuid

  def self.match?(url)
    url.host.in?(%w[skeb.jp skeb.imgix.net skeb-production.s3.ap-northeast-1.amazonaws.com])
  end

  def parse
    case [domain, *path_segments]

    # https://skeb.jp/@OrvMZ/works/3 (non-watermarked)
    # https://skeb.jp/@OrvMZ/works/1 (separated request and client's message after delivery)
    # https://skeb.jp/@asanagi/works/16 (age-restricted, watermarked)
    # https://skeb.jp/@asanagi/works/6 (private, returns 404)
    # https://skeb.jp/@nasuno42/works/30 (multi-image post)
    in "skeb.jp", /^@/ => username, "works", work_id
      @username = username.delete_prefix("@")
      @work_id = work_id

    # https://skeb.jp/@asanagi
    # https://skeb.jp/@okku_oxn/works
    in "skeb.jp", /^@/ => username, *rest
      @username = username.delete_prefix("@")

    # https://skeb.imgix.net/requests/199886_0?bg=%23fff&auto=format&w=800&s=5a6a908ab964fcdfc4713fad179fe715
    # https://skeb.imgix.net/requests/73290_0?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&w=800&s=4843435cff85d623b1f657209d131526
    # https://skeb.imgix.net/requests/53269_1?bg=%23fff&fm=png&dl=53269.png&w=1.0&h=1.0&s=44588ea9c41881049e392adb1df21cce (full size)
    in "imgix.net", "requests", image_id
      @image_id = image_id

    # https://skeb.imgix.net/uploads/origins/04d62c2f-e396-46f9-903a-3ca8bd69fc7c?bg=%23fff&auto=format&w=800&s=966c5d0389c3b94dc36ac970f812bef4
    in "imgix.net", "uploads", "origins", image_uuid
      @image_uuid = image_uuid

    # Page: https://skeb.jp/@kaisouafuro/works/112
    # https://skeb-production.s3.ap-northeast-1.amazonaws.com/uploads/outputs/20f9d68f-50ec-44ae-8630-173fc38a2d6a?response-content-disposition=attachment%3B%20filename%3D%22458093-1.output.mp4%22%3B%20filename%2A%3DUTF-8%27%27458093-1.output.mp4&response-content-type=video%2Fmp4&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVPUTFQBBL7UDSUA%2F20220221%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20220221T200057Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=7f028cfd9a56344cf1d42410063fad3ef30a1e47b83cef047247e0c37df01df0
    in "amazonaws.com", "uploads", "outputs", image_uuid
      @image_uuid = image_uuid

    else
    end
  end

  def profile_url
    "https://skeb.jp/@#{username}" if username.present?
  end

  def image_url?
    domain.in?(%[imgix.net amazonaws.com])
  end

  def animated?
    image_url? && params[:fm].in?(["gif", "mp4"])
  end

  def watermarked?
    image_url? && params[:txt].present?
  end
end
