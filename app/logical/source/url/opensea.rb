# frozen_string_literal: true

# @see Source::Extractor::Opensea
class Source::URL::Opensea < Source::URL
  RESERVED_USERNAMES = %w[about account activity assets blog careers category collection drops learn partners privacy studio tos rankings]

  attr_reader :username, :user_id, :chain, :contract_id, :token_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[opensea.io openseauserdata.com seadn.io])
  end

  def site_name
    "OpenSea"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://i.seadn.io/s/raw/files/473d8a4978c86ede320b8372dfe2a8b3.png?auto=format&dpr=1&w=384 (sample)
    # https://i.seadn.io/s/raw/files/473d8a4978c86ede320b8372dfe2a8b3.png (full)
    in "i", "seadn.io", "s", "raw", "files", _
      @full_image_url = without(:query).to_s

    # https://i.seadn.io/gae/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA?auto=format&dpr=1&w=1000 (sample)
    # https://i.seadn.io/gae/CnA27YghZgRXfI35roMJts6x43S6xwjkBqXF2ujywUl5ibx9Gd16TKsPwVBEyYyszO96XbWx85HzoGxQ6JI6FHQpjZ5YvEZo1CHxVA?w=99999 (full)
    in "i", "seadn.io", "gae", file
      @full_image_url = "https://lh3.googleusercontent.com/#{file}=d"

    # https://opensea.io/assets/matic/0x2953399124f0cbb46d2cbacd8a89cf0599974963/73367181727578658379392940909024713110943326450271164125938382654208802291713
    # https://opensea.io/assets/ethereum/0x495f947276749ce646f68ac8c248420045cb7b5e/47707087614834185592401815072389651465878170492683018350293856127512379129861
    in _, "opensea.io", "assets", chain, contract_id, token_id
      @chain = chain
      @contract_id = contract_id
      @token_id = token_id

    # https://opensea.io/0x7C01A933e8761DDf96C2322c772FbD2527ded439
    in _, "opensea.io", /^0x\h{39}/ => user_id
      @user_id = user_id

    # https://opensea.io/accounts/0xff605910dc69999dca1fe2fa289a43cc2d51f0fc
    in _, "opensea.io", "accounts", /^0x\h{39}/ => user_id
      @user_id = user_id

    # https://opensea.io/tororotororo
    # https://opensea.io/tororotororo/created
    # https://opensea.io/McArtCollection?tab=created
    # https://opensea.io/tama5.eth (Ethereum Name Service (ENS) name)
    in _, "opensea.io", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://openseauserdata.com/files/56abded53392efcc6898d0680892bf5e.png
    # https://dl.openseauserdata.com/cache/originImage/files/56abded53392efcc6898d0680892bf5e.png
    # https://i.seadn.io/s/primary-drops/0xc274a97f1691ef390f662067e95a6eff1f99b504/31341974:about:media:98e2f8a2-a8aa-46d9-9267-87108353c759.jpeg?auto=format&dpr=1&w=1920 (profile banner)
    # https://opensea.io/collection/illustration-ainousoko
    else
      nil
    end
  end

  def image_url?
    domain.in?(%w[openseauserdata.com seadn.io])
  end

  def page_url
    "https://opensea.io/assets/#{chain}/#{contract_id}/#{token_id}" if chain.present? && contract_id.present? && token_id.present?
  end

  def profile_url
    if username.present?
      "https://opensea.io/#{username}"
    elsif user_id.present?
      "https://opensea.io/#{user_id}"
    end
  end
end
