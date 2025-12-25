# frozen_string_literal: true

# Note: even if the username is wrong, the url is still resolved correctly. Example:
# * https://foundation.app/@foundation/~/97376
#
# Unsupported patterns:
# * https://foundation.app/@ <- This seems to be a novelty account.
# * https://foundation.app/mochiiimo <- no @
# * https://foundation.app/collection/kgfgen

class Source::URL::Foundation < Source::URL
  attr_reader :username, :user_id, :token_id, :work_id, :slug, :hash, :collection

  IMAGE_HOSTS = %w[assets.foundation.app f8n-ipfs-production.imgix.net f8n-production-collection-assets.imgix.net d2ybmb80bbm9ts.cloudfront.net]

  def self.match?(url)
    url.host.in?(%w[foundation.app assets.foundation.app]) || url.host.in?(IMAGE_HOSTS)
  end

  def parse
    case [host, *path_segments]

    # https://foundation.app/@mochiiimo
    # https://foundation.app/@KILLERGF
    in "foundation.app", /^@/ => username
      @username = username.delete_prefix("@")

    # https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2
    in "foundation.app", /^0x\h{39}/ => user_id
      @user_id = user_id

    # https://foundation.app/@mochiiimo/foundation/97376
    # https://foundation.app/@KILLERGF/kgfgen/4
    # https://foundation.app/@mochiiimo/~/97376
    # https://foundation.app/@~/~/6792
    in "foundation.app", /^@/ => username, collection, /^\d+/ => work_id
      @username = username.delete_prefix("@") unless username == "@~"
      @collection = collection unless collection == "~"
      @work_id = work_id

    # https://foundation.app/@asuka111art/dinner-with-cats-82426
    in "foundation.app", /^@/ => username, /\d+$/ => slug
      @username = username.delete_prefix("@")
      @slug, _, @work_id = slug.rpartition("-")

    # https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4
    # https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/6
    # https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/109433
    in "foundation.app", "mint", "eth", /^0x\h{39}/ => token_id, work_id
      @token_id = token_id
      @work_id = work_id

    # https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png
    # https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png?q=80&auto=format%2Ccompress&cs=srgb&max-w=1680&max-h=1680
    in "f8n-ipfs-production.imgix.net", hash, file
      @hash = hash

    # https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png
    in "f8n-production-collection-assets.imgix.net", /^0x\w{40}$/ => token_id, work_id, hash, file
      @token_id = token_id
      @work_id = work_id
      @hash = hash

    # https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png
    # https://assets.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4
    in ("f8n-production-collection-assets.imgix.net" | "assets.foundation.app"), /^0x\w{40}$/ => token_id, work_id, file
      @token_id = token_id
      @work_id = work_id

    # https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4
    # https://d2ybmb80bbm9ts.cloudfront.net/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft_q4.mp4
    in ("assets.foundation.app" | "d2ybmb80bbm9ts.cloudfront.net"), *subdirs, hash, file
      @hash = hash

    else
      nil
    end
  end

  def image_url?
    host.in?(IMAGE_HOSTS)
  end

  def profile_url
    if username.present?
      "https://foundation.app/@#{username}"
    elsif user_id.present?
      "https://foundation.app/#{user_id}"
    end
  end

  def page_url
    if token_id.present? && work_id.present?
      "https://foundation.app/mint/eth/#{token_id}/#{work_id}"
    elsif work_id.present?
      "https://foundation.app/@#{username || "foundation"}/#{collection || "foundation"}/#{work_id}"
    end
  end

  def full_image_url
    if hash.present? && file_ext.present?
      "https://f8n-ipfs-production.imgix.net/#{hash}/nft.#{file_ext}"
    elsif host == "f8n-production-collection-assets.imgix.net" && token_id.present? && work_id.present? && file_ext.present?
      "https://f8n-production-collection-assets.imgix.net/#{token_id}/#{work_id}/nft.#{file_ext}"
    elsif file_ext.present?
      without(:query).to_s
    end
  end

  def ipfs_url
    "ipfs://#{hash}/nft.#{file_ext}" if hash.present? && file_ext.present?
  end
end
