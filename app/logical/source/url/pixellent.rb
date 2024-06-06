# frozen_string_literal: true

# @see Source::Extractor::Pixellent
class Source::URL::Pixellent < Source::URL
  attr_reader :full_image_url, :username, :user_id, :post_id

  def self.match?(url)
    url.domain == "pixellent.me" || ([url.host, *url.path_segments] in "firebasestorage.googleapis.com", "v0", "b", "pixellent.appspot.com", *)
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Favatars%2Fthumbnail-d80.avif?alt=media&v1706935603004 (profile picture)
    # https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Fthumbnail-d1280.jpg?alt=media&v1709194337242 (sample)
    # https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Fthumbnail-full.jpg?alt=media (sample)
    # https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/users%2FUbwtLvQnfEcV4d4IhAFztXXghR03%2Fposts%2Fs89Uq4Zwq8CVHQhpQ26B%2Fimages%2Foriginal?alt=media (full)
    in "firebasestorage", "googleapis.com", "v0", "b", "pixellent.appspot.com", "o", subpath
      # segments == ["users", "UbwtLvQnfEcV4d4IhAFztXXghR03", "posts", "s89Uq4Zwq8CVHQhpQ26B", "images", "thumbnail-d1280.jpg"]
      segments = Danbooru::URL.unescape(subpath).split("/")

      if segments in ["users", user_id, "posts", post_id, "images", _]
        @user_id = user_id
        @post_id = post_id
        file = "users/#{user_id}/posts/#{post_id}/images/original"
        @full_image_url = "https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/#{Danbooru::URL.escape(file)}?alt=media"
      end

    # https://pixellent.me/p/s89Uq4Zwq8CVHQhpQ26B
    in _, "pixellent.me", "p", post_id
      @post_id = post_id

    # https://pixellent.me/@u-UbwtLvQnfEcV4d4IhAFztXXghR03 (user id for @shina)
    in _, "pixellent.me", /^@u-/ => user_id, *rest
      @user_id = user_id.delete_prefix("@u-")

    # https://pixellent.me/@shina
    in _, "pixellent.me", /^@/ => username, *rest
      @username = username.delete_prefix("@")

    else
      nil
    end
  end

  def page_url
    "https://pixellent.me/p/#{post_id}" if post_id.present?
  end

  def profile_url
    if username.present?
      "https://pixellent.me/@#{username}"
    elsif user_id.present?
      "https://pixellent.me/@u-#{user_id}"
    end
  end
end
