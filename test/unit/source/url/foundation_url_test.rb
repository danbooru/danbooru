require "test_helper"

module Source::Tests::URL
  class FoundationUrlTest < ActiveSupport::TestCase
    context "Foundation URLs" do
      should be_image_url(
        "https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png",
        "https://f8n-production-collection-assets.imgix.net/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/128711/QmcBfbeCMSxqYB3L1owPAxFencFx3jLzCPFx6xUBxgSCkH/nft.png",
        "https://f8n-production-collection-assets.imgix.net/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4/nft.png",
        "https://f8n-production-collection-assets.imgix.net/1/0xA56aA69B9bb03c9db627f5483eAbf92dbF39dcDC/11/nft.jpg",
        "https://assets.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4",
        "https://assets.foundation.app/7i/gs/QmU8bbsjaVQpEKMDWbSZdDD6GsPmRYBhQtYRn8bEGv7igs/nft_q4.mp4",
        "https://d2ybmb80bbm9ts.cloudfront.net/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft_q4.mp4",
        "https://video.prod.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4",
        "https://video.prod.foundation.app/1/0xf062FB529334935C2eB179BfAb3b56fbcd668FFe/4/nft.jpg",
        "https://video.prod.foundation.app/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft.mp4",
        "https://assets.prod.foundation.app/resized/MS8weEE1NmFBNjlCOWJiMDNjOWRiNjI3ZjU0ODNlQWJmOTJkYkYzOWRjREMvMTEvbmZ0LmpwZw__w1200-h1200.webp",
      )

      should be_page_url(
        "https://foundation.app/@asuka111art/dinner-with-cats-82426",
        "https://foundation.app/@mochiiimo/~/97376",
        "https://foundation.app/mint/eth/0xFb0a8e1bB97fD7231Cd73c489dA4732Ae87995F0/4",
        "https://foundation.app/mint/eth/0x3B3ee1931Dc30C1957379FAc9aba94D1C48a5405/109433",
      )

      should be_profile_url(
        "https://foundation.app/@mochiiimo",
        "https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2",
      )

      should be_secondary_url(
        "https://foundation.app/0x7E2ef75C0C09b2fc6BCd1C68B6D409720CcD58d2",
      )

      should_not be_secondary_url(
        "https://foundation.app/@mochiiimo",
      )

      should parse_url("https://assets.prod.foundation.app/resized/MS8weEE1NmFBNjlCOWJiMDNjOWRiNjI3ZjU0ODNlQWJmOTJkYkYzOWRjREMvMTEvbmZ0LmpwZw__w1200-h1200.webp").into(
        full_image_url: "https://assets.prod.foundation.app/resized/MS8weEE1NmFBNjlCOWJiMDNjOWRiNjI3ZjU0ODNlQWJmOTJkYkYzOWRjREMvMTEvbmZ0LmpwZw.webp",
      )

      should parse_url("https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png?q=80&auto=format%2Ccompress&cs=srgb&max-w=1680&max-h=1680").into(
        full_image_url: "https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png",
      )

      should parse_url("https://video.prod.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4").into(
        full_image_url: "https://video.prod.foundation.app/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4/nft.mp4",
        page_url: "https://foundation.app/mint/eth/0x21Afa9aB02B6Fb7cb483ff3667c39eCdd6D9Ea73/4",
      )

      should parse_url("https://video.prod.foundation.app/1/0xf062FB529334935C2eB179BfAb3b56fbcd668FFe/4/nft.jpg").into(
        full_image_url: "https://video.prod.foundation.app/1/0xf062FB529334935C2eB179BfAb3b56fbcd668FFe/4/nft.jpg",
        page_url: "https://foundation.app/mint/eth/0xf062FB529334935C2eB179BfAb3b56fbcd668FFe/4",
      )

      should parse_url("https://video.prod.foundation.app/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft.mp4").into(
        full_image_url: "https://video.prod.foundation.app/zd/BD/QmXiCEoBLcpfvpEwAEanLXe3Tjr5ykYJFzCVfpzDDQzdBD/nft.mp4",
      )

      should parse_url("https://f8n-production-collection-assets.imgix.net/1/0xA56aA69B9bb03c9db627f5483eAbf92dbF39dcDC/11/nft.jpg").into(
        full_image_url: "https://f8n-production-collection-assets.imgix.net/1/0xA56aA69B9bb03c9db627f5483eAbf92dbF39dcDC/11/nft.jpg",
        page_url: "https://foundation.app/mint/eth/0xA56aA69B9bb03c9db627f5483eAbf92dbF39dcDC/11",
      )
    end

    should parse_url("https://f8n-ipfs-production.imgix.net/QmX4MotNAAj9Rcyew43KdgGDxU1QtXemMHoUTNacMLLSjQ/nft.png").into(site_name: "Foundation")
  end
end
