require "test_helper"

module Source::Tests::URL
  class FoundationUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png",
          "https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png",
          "https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png",
          "https://assets.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4",
          "https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4",
          "https://d2ybmb80bbm9ts.cloudfront.net/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft_q4.mp4",
        ],
        page_urls: [
          "https://foundation.app/@asuka111art/dinner-with-cats-82426",
          "https://foundation.app/@mochiiimo/~/97376",
          "https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4",
          "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/109433",
        ],
        profile_urls: [
          "https://foundation.app/@mochiiimo",
          "https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2",
        ],
      )
    end
  end
end
