# frozen_string_literal: true
#
# Page URLs
#
# * https://foundation.app/@mochiiimo/~/97376
# * https://foundation.app/@mochiiimo/foundation/97376
# * https://foundation.app/@KILLERGF/kgfgen/4
# * https://foundation.app/@huwari/~/88982 (video)
# * https://foundation.app/@asuka111art/dinner-with-cats-82426 (redirects to https://foundation.app/@asuka111art/foundation/82426)
#
# Even if the username is wrong, the ID is still fetched correctly. Example:
#
# * https://foundation.app/@foundation/~/97376
#
# Full image URLs
#
# # Page: https://foundation.app/@mochiiimo/~/97376
# * https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png
# * https://ipfs.io/ipfs/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png
#
# # Page: https://foundation.app/@mochiiimo/~/128711
# * https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png
# * https://f8n-ipfs-production.imgix.net/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png
# * https://ipfs.io/ipfs/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png
#
# # Page: https://foundation.app/@KILLERGF/kgfgen/4
# * https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png
# * https://ipfs.io/ipfs/QmbdxcWQ9bg6JUMfK4ubpW2rGDFA8qfTidoCaf6GKMqvr7/nft.png
#
# Video URLs
#
# # Page: https://foundation.app/@huwari/foundation/88982
# * https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4
# * https://f8n-ipfs-production.imgix.net/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft.mp4
# * https://ipfs.io/ipfs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft.mp4
#
# Sample image URLs
#
# * https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png?q=80&auto=format%2Ccompress&cs=srgb&max-w=1680&max-h=1680
# * https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png?q=80&auto=format%2Ccompress&cs=srgb&h=640
#
# Profile URLs
#
# Profile urls seem to accept any character in them, even no character at all:
#
# * https://foundation.app/@mochiiimo
# * https://foundation.app/@ <- This seems to be a novelty account.
#
# Public key profile URLs:
#
# * https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2 (@mochiiimo)
#
# The @ is optional:
#
# * https://foundation.app/mochiiimo
#
class Source::URL::Foundation < Source::URL
  attr_reader :username, :token_id, :work_id, :hash

  def self.match?(url)
    url.host.in?(%w[foundation.app assets.foundation.app f8n-ipfs-production.imgix.net f8n-production-collection-assets.imgix.net])
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

    # https://foundation.app/@mochiiimo/~/97376
    # https://foundation.app/@mochiiimo/foundation/97376
    # https://foundation.app/@KILLERGF/kgfgen/4
    in "foundation.app", /^@/ => username, collection, /^\d+/ => work_id
      @username = username.delete_prefix("@")
      @collection = collection
      @work_id = work_id

    # https://foundation.app/@asuka111art/dinner-with-cats-82426
    in "foundation.app", /^@/ => username, /^.+-\d+$/ => slug
      @username = username.delete_prefix("@")
      @work_id = slug.split("-").last

    # https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png
    # https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png?q=80&auto=format%2Ccompress&cs=srgb&max-w=1680&max-h=1680
    in "f8n-ipfs-production.imgix.net", hash, file
      @hash = hash

    # https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png
    in "f8n-production-collection-assets.imgix.net", token_id, work_id, hash, file
      @token_id = token_id
      @work_id = work_id
      @hash = hash

    # https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png
    in "f8n-production-collection-assets.imgix.net", token_id, work_id, file
      @token_id = token_id
      @work_id = work_id

    # https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4
    in "assets.foundation.app", *subdirs, hash, file
      @hash = hash

    else
    end
  end

  def page_url
    return nil unless work_id.present?

    username = @username || "foundation"
    collection = @collection || "foundation"
    "https://foundation.app/@#{username}/#{collection}/#{work_id}"
  end

  def full_image_url
    if hash.present? && file_ext.present?
      "https://f8n-ipfs-production.imgix.net/#{hash}/nft.#{file_ext}"
    elsif host == "f8n-production-collection-assets.imgix.net" && token_id.present? && work_id.present? && file_ext.present?
      "https://f8n-production-collection-assets.imgix.net/#{token_id}/#{work_id}/nft.#{file_ext}"
    end
  end

  def ipfs_url
    return nil unless hash.present? && file_ext.present?
    "ipfs://#{hash}/nft.#{file_ext}"
  end
end
