# frozen_string_literal: true

class Source::URL::Misskey < Source::URL
  attr_reader :username, :user_id, :note_id

  def self.match?(url)
    url.domain.in?(%w[misskey.io misskey.art misskey.design]) ||
      (url.host == "media.misskeyusercontent.com" && url.path.starts_with?("/io/")) ||
      (url.host == "s3.arkjp.net" && url.path.starts_with?("/misskey/"))
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

    else
      nil
    end
  end

  def site_name
    if host.in?(%w[s3.arkjp.net media.misskeyusercontent.com])
      "Misskey.io"
    else
      domain.capitalize
    end
  end

  def image_url?
    host.in?(%w[s3.arkjp.net media.misskeyusercontent.com]) ||
      (host == "misskey.art" && path.starts_with?("/files/")) ||
      (host == "misskey.design" && path.starts_with?("/post/"))
  end

  def page_url
    if note_id.present?
      "https://#{domain}/notes/#{note_id}"
    end
  end

  def profile_url
    if username.present?
      "https://#{domain}/@#{username}"
    elsif user_id.present?
      "https://#{domain}/users/#{user_id}"
    end
  end
end
