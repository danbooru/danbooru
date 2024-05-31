# frozen_string_literal: true

class Source::URL::Bluesky < Source::URL
  attr_reader :user_did, :user_handle, :post_id

  def self.match?(url)
    url.domain.in?(%w[bsky.app bsky.social bsky.network])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://bsky.app/profile/ixy.bsky.social
    # https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w
    in _, _, "profile", user_id
      if user_id.starts_with?("did:")
        @user_did = user_id
      else
        @user_handle = user_id
      end

    # https://bsky.app/profile/ixy.bsky.social/post/3kkvo4d4jd32g
    # https://bsky.app/profile/did:plc:3jogsxcisdcdzwjobhxbav2w/post/3kkvo4d4jd32g
    in _, _, "profile", user_id, "post", post_id
      if user_id.starts_with?("did:")
        @user_did = user_id
      else
        @user_handle = user_id
      end

      @post_id = post_id

    # https://cdn.bsky.app/img/feed_fullsize/plain/did:plc:3jogsxcisdcdzwjobhxbav2w/bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4@jpeg
    in _, _, "img", _, "plain", did, cid
      @user_did = did
      @image_cid = cid.split("@").first

    # https://bsky.social/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4
    # https://morel.us-east.host.bsky.network/xrpc/com.atproto.sync.getBlob?did=did:plc:3jogsxcisdcdzwjobhxbav2w&cid=bafkreiawa4vn5k37h2mlpwuhaqmeog3hsfe3z47iot7reqxjlff6juyge4
    in _, _, "xrpc", "com.atproto.sync.getBlob" if params["did"].present? && params["cid"].present?
      @user_did = params["did"]
      @image_cid = params["cid"]

    # https://ixy.bsky.social
    in username, "bsky.social"
      @user_handle = "#{username}.bsky.social"

    else
      nil
    end
  end

  def image_url?
    host == "cdn.bsky.app" || path == "/xrpc/com.atproto.sync.getBlob"
  end

  def full_image_url
    "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=#{user_did}&cid=#{@image_cid}"
  end

  def page_url
    "#{profile_url}/post/#{post_id}" if post_id.present?
  end

  def profile_url
    if user_handle.present?
      "https://bsky.app/profile/#{user_handle}"
    elsif user_did.present?
      "https://bsky.app/profile/#{user_did}"
    end
  end
end
