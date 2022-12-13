# frozen_string_literal: true

class Source::URL::Anifty < Source::URL
  attr_reader :username, :artist_hash, :work_id, :file, :work_type

  def self.match?(url)
    url.domain == "anifty.jp" || url.host == "anifty.imgix.net" || (url.host == "storage.googleapis.com" && url.path.include?("/anifty-media/"))
  end

  def parse
    case [host, *path_segments]

    # https://anifty.imgix.net/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/20d5ce5b5163a71258e1d0ee152a0347bf40c7da.png?w=660&h=660&fit=crop&crop=focalpoint&fp-x=0.76&fp-y=0.5&fp-z=1&auto=compress
    # https://anifty.imgix.net/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/48b1409838cf7271413480b8533372844b9f2437.png?w=3840&q=undefined&auto=compress
    in "anifty.imgix.net", work_type, /^0x\w+$/ => artist_hash, file
      @artist_hash = artist_hash
      @file = file
      @work_type = work_type

    # https://storage.googleapis.com/anifty-media/creation/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/20d5ce5b5163a71258e1d0ee152a0347bf40c7da.png
    # https://storage.googleapis.com/anifty-media/profile/0x961d09077b4a9f7a27f6b7ee78cb4c26f0e72c18/a6d2c366a3e876ddbf04fc269b63124be18af424.png
    in "storage.googleapis.com", "anifty-media", work_type, /^0x\w+$/ => artist_hash, file
      @artist_hash = artist_hash
      @file = file
      @work_type = work_type

    # https://anifty.jp/creations/373
    # https://anifty.jp/ja/creations/373
    # https://anifty.jp/zh/creations/373
    # https://anifty.jp/zh-Hant/creations/373
    in ("anifty.jp" | "www.anifty.jp"), *, "creations", /^\d+$/ => work_id
      @work_id = work_id

    # https://anifty.jp/@hightree
    # https://anifty.jp/ja/@hightree
    in ("anifty.jp" | "www.anifty.jp"), *, /^@(\w+)$/
      @username = $1

    else
      nil
    end
  end

  def image_url?
    file.present? && artist_hash.present?
  end

  def full_image_url
    "https://storage.googleapis.com/anifty-media/#{work_type}/#{artist_hash}/#{file}" if image_url?
  end

  def page_url
    "https://anifty.jp/creations/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://anifty.jp/@#{username}" if username.present?
  end
end
