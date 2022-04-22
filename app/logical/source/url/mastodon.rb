# frozen_string_literal: true

# Unparsed:
#
# OAuth URL: (Note: ID is different from account URL ID)
# * https://pawoo.net/oauth_authentications/17230064

class Source::URL::Mastodon < Source::URL
  attr_reader :username, :user_id, :work_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[pawoo.net baraag.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://pawoo.net/@evazion/19451018
    # https://baraag.net/@curator/102270656480174153
    in _, _, /^@/ => username, /^\d+$/ => work_id, *rest
      @username = username.delete_prefix("@")
      @work_id = work_id

    # https://pawoo.net/@evazion
    # https://baraag.net/@danbooru
    # https://baraag.net/@quietvice/media
    in _, _, /^@/ => username, *rest
      @username = username.delete_prefix("@")

    # https://pawoo.net/users/esoraneko
    # https://pawoo.net/users/khurata/media
    in _, _, "users", username, *rest
      @username = username

    # https://pawoo.net/web/statuses/19451018
    # https://pawoo.net/web/statuses/19451018/favorites
    # https://baraag.net/web/statuses/102270656480174153
    in _, _, "web", "statuses", work_id, *rest
      @work_id = work_id

    # https://pawoo.net/web/accounts/47806
    # https://baraag.net/web/accounts/107862785324786980
    in _, _, "web", "accounts", user_id
      @user_id = user_id

    # Page: https://pawoo.net/@evazion/19451018
    # https://img.pawoo.net/media_attachments/files/001/297/997/small/c4272a09570757c2.png
    # https://img.pawoo.net/media_attachments/files/001/297/997/original/c4272a09570757c2.png
    in "img", "pawoo.net", "media_attachments", "files", *subdirs, file_size, file
      @file_size = file_size
      @full_image_url = "#{site}/media_attachments/files/#{subdirs.join("/")}/original/#{file}"

    # Page: https://baraag.net/@danbooru/107866090743238456
    # https://baraag.net/system/media_attachments/files/107/866/084/749/942/932/original/a9e0f553e332f303.mp4
    # https://baraag.net/system/media_attachments/files/107/866/084/754/127/256/original/3895a14ce3736f13.mp4
    # https://baraag.net/system/media_attachments/files/107/866/084/754/651/925/original/8f3df857681a1639.png
    in _, "baraag.net", "system", "media_attachments", "files", *subdirs, file_size, file
      @file_size = file_size
      @full_image_url = "#{site}/system/media_attachments/files/#{subdirs.join("/")}/original/#{file}"

    # https://pawoo.net/media/lU2uV7C1MMQSb1czwvg
    in _, "pawoo.net", "media", media_hash
      @media_hash = media_hash

    else
      nil
    end
  end

  def site_name
    case domain
    when "pawoo.net" then "Pawoo"
    when "baraag.net" then "Baraag"
    end
  end

  def image_url?
    full_image_url.present?
  end

  def page_url
    if username.present? && work_id.present?
      "https://#{domain}/@#{username}/#{work_id}"
    elsif work_id.present?
      "https://#{domain}/web/statuses/#{work_id}"
    end
  end

  def profile_url
    if username.present?
      "https://#{domain}/@#{username}"
    elsif user_id.present?
      "https://#{domain}/web/accounts/#{user_id}"
    end
  end
end
