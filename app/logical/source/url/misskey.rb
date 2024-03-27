# frozen_string_literal: true

class Source::URL::Misskey < Source::URL
  attr_reader :username, :user_id, :note_id

  def self.match?(url)
    url.domain.in?(%w[misskey.io misskey.art misskey.design misskeyusercontent.com misskeyusercontent.jp]) || url.host.match?(/\A(s3|nos3)\.arkjp\.net\z/)
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://misskey.io/@ixy194
    # https://misskey.io/@ixy194/followers
    in _, _, /^@/ => username, *rest
      @username = username.delete_prefix("@")

    # https://misskey.io/users/9bpemdns40
    # https://misskey.io/user-info/9bpemdns40
    in _, _, ("users" | "user-info"), user_id
      @user_id = user_id

    # https://misskey.io/notes/9bxaf592x6
    in _, _, "notes", note_id
      @note_id = note_id

    # https://media.misskeyusercontent.jp/io/dfca7bd4-c073-4ea0-991f-313ab3a77847.png
    # https://media.misskeyusercontent.com/io/thumbnail-e9f307e4-3fad-435f-91b6-3768d688491d.webp | https://misskey.io/notes/9hfx0ezipu
    # https://media.misskeyusercontent.com/io/webpublic-a2cdd9c7-0449-4a61-b453-b5c7b2134677.png
    # https://proxy.misskeyusercontent.com/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F111%2F232%2F575%2F490%2F284%2F147%2Foriginal%2F9aaf0c71a41b5647.jpeg | https://misskey.io/notes/9ktdpaq840
    # https://media.misskeyusercontent.com/misskey/7d2adf4a-b2dd-40b4-ba27-916e44f7bd48.png | https://misskey.io/notes/9bxaf592x6
    # https://nos3.arkjp.net/image.webp?url=https%3A%2F%2Fimg.pawoo.net%2Fmedia_attachments%2Ffiles%2F110%2F314%2F466%2F230%2F358%2F806%2Foriginal%2F6fbcc38659d3cb97.jpeg | https://misskey.io/notes/9edoxxq8h8
    # https://s3.arkjp.net/misskey/930fe4fb-c07b-4439-804e-06fb472d698f.gif | https://misskey.io/notes/9dd5xo5zda
    # https://files.misskey.art//webpublic-94d9354f-ddba-406b-b878-4ce02ccfa505.webp | https://misskey.art/notes/9pjpq1zrcy
    # https://file.misskey.design/post/webpublic-ac7072e9-812f-460b-ad24-1f303a62f0b4.webp | https://misskey.design/notes/9r8c6x1n1p
    in _, _, *path if file_ext.in?(%w[jpg jpeg png gif webp webm mp4])
      @image_url = true

    else
      nil
    end
  end

  def site_name
    case domain
    in "arkjp.net", "misskeyusercontent.com", "misskeyusercontent.jp"
      "Misskey.io"
    else
      domain.capitalize
    end
  end

  def image_url?
    @image_url
  end

  def page_url
    if note_id.present?
      "https://#{host}/notes/#{note_id}"
    end
  end

  def profile_url
    if username.present?
      "https://#{host}/@#{username}"
    elsif user_id.present?
      "https://#{host}/users/#{user_id}"
    end
  end
end
