# frozen_string_literal: true

require "test_helper"

module Source::Tests::URL
  class DlsiteUrlTest < ActiveSupport::TestCase
    context "Dlsite URLs" do
      should be_image_url(
        "https://img.dlsite.jp/modpub/images2/work/doujin/RJ01183000/RJ01182574_img_main.jpg",
        "https://img.dlsite.jp/modpub/images2/ana/doujin/RJ01571000/RJ01570715_ana_img_main.webp",
        "https://img.dlsite.jp/modpub/images2/parts/RJ01109000/RJ01108646/c595ec4d121d80c300d94b368806d655.jpg",
        "https://img.dlsite.jp/modpub/images2/parts_ana/RJ01030000/RJ01029765/33415f94d0cf83d85f39624dac1e3724.jpg",
      )

      should be_page_url(
        "https://www.dlsite.com/home/work/=/product_id/RJ01096697",
        "https://www.dlsite.com/home/work/=/product_id/RJ01096697.html",
        "https://www.dlsite.com/maniax/work/=/product_id/RJ01134569.html",
        "https://www.dlsite.com/maniax/announce/=/product_id/RJ01137148.html",
        "https://www.dlsite.com/maniax-touch/announce/=/product_id/RJ01110853.html",
        "https://www.dlsite.com/girls/work/=/product_id/RJ01345621.html",
        "https://www.dlsite.com/bl/work/=/product_id/RJ01329452.html",
        "https://www.dlsite.com/pro/work/=/product_id/VJ015443.html",
        "https://www.dlsite.com/books/work/=/product_id/BJ181344.html",
        "https://www.dlsite.com/eng/work/=/product_id/RE277378.html",
        "https://www.dlsite.com/ecchi-eng/work/=/product_id/RE028506.html",
        "https://www.dlsite.com/ecchi-eng-touch/work/=/product_id/RE166667.html",
        "https://www.dlsite.com/ecchi-eng/announce/=/product_id/RE155768.html",
        "https://eng.dlsite.com/work/=/product_id/RE036764",
        "https://eng.dlsite.com/work/=/product_id/RE022725.html",
        "http://maniax.dlsite.com/work/=/product_id/RJ072689.html",
      )

      should be_profile_url(
        "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689",
        "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689.html",
        "https://www.dlsite.com/maniax-touch/circle/profile/=/maker_id/RG64022.html",
        "https://www.dlsite.com/home/circle/profile/=/maker_id/RG64308.html",
        "https://www.dlsite.com/ecchi-eng/circle/profile/=/maker_id/RG05689.html",
        "https://www.dlsite.com/girls/circle/profile/=/maker_id/RG70492.html",
        "https://www.dlsite.com/bl/circle/profile/=/maker_id/RG11630.html",
        "https://www.dlsite.com/books/author/=/author_id/AJ010529",
        "https://www.dlsite.com/comic/author/=/author_id/AJ010529",
        "https://www.dlsite.com/maniax/author/=/author_id/AJ010452",
      )

      should parse_url("https://img.dlsite.jp/modpub/images2/work/doujin/RJ01183000/RJ01182574_img_main.jpg").into(
        page_url: "https://www.dlsite.com/maniax/work/=/product_id/RJ01182574.html",
      )
      should parse_url("https://img.dlsite.jp/modpub/images2/ana/doujin/RJ01571000/RJ01570715_ana_img_main.webp").into(
        page_url: "https://www.dlsite.com/maniax/announce/=/product_id/RJ01570715.html",
      )
      should parse_url("https://img.dlsite.jp/modpub/images2/parts/RJ01109000/RJ01108646/c595ec4d121d80c300d94b368806d655.jpg").into(
        page_url: "https://www.dlsite.com/maniax/work/=/product_id/RJ01108646.html",
      )
      should parse_url("https://img.dlsite.jp/modpub/images2/parts_ana/RJ01030000/RJ01029765/33415f94d0cf83d85f39624dac1e3724.jpg").into(
        page_url: "https://www.dlsite.com/maniax/announce/=/product_id/RJ01029765.html",
      )
      should parse_url("https://www.dlsite.com/home/work/=/product_id/RJ01096697").into(
        page_url: "https://www.dlsite.com/home/work/=/product_id/RJ01096697.html",
      )
      should parse_url("https://www.dlsite.com/home/work/=/product_id/RJ01096697.html").into(
        page_url: "https://www.dlsite.com/home/work/=/product_id/RJ01096697.html",
      )
      should parse_url("https://www.dlsite.com/maniax/work/=/product_id/RJ01134569.html").into(
        page_url: "https://www.dlsite.com/maniax/work/=/product_id/RJ01134569.html",
      )
      should parse_url("https://www.dlsite.com/maniax/announce/=/product_id/RJ01137148.html").into(
        page_url: "https://www.dlsite.com/maniax/announce/=/product_id/RJ01137148.html",
      )
      should parse_url("https://www.dlsite.com/maniax-touch/announce/=/product_id/RJ01110853.html").into(
        page_url: "https://www.dlsite.com/maniax-touch/announce/=/product_id/RJ01110853.html",
      )
      should parse_url("https://www.dlsite.com/girls/work/=/product_id/RJ01345621.html").into(
        page_url: "https://www.dlsite.com/girls/work/=/product_id/RJ01345621.html",
      )
      should parse_url("https://www.dlsite.com/bl/work/=/product_id/RJ01329452.html").into(
        page_url: "https://www.dlsite.com/bl/work/=/product_id/RJ01329452.html",
      )
      should parse_url("https://www.dlsite.com/pro/work/=/product_id/VJ015443.html").into(
        page_url: "https://www.dlsite.com/pro/work/=/product_id/VJ015443.html",
      )
      should parse_url("https://www.dlsite.com/books/work/=/product_id/BJ181344.html").into(
        page_url: "https://www.dlsite.com/books/work/=/product_id/BJ181344.html",
      )
      should parse_url("https://www.dlsite.com/eng/work/=/product_id/RE277378.html").into(
        page_url: "https://www.dlsite.com/eng/work/=/product_id/RE277378.html",
      )
      should parse_url("https://www.dlsite.com/ecchi-eng/work/=/product_id/RE028506.html").into(
        page_url: "https://www.dlsite.com/ecchi-eng/work/=/product_id/RE028506.html",
      )
      should parse_url("https://www.dlsite.com/ecchi-eng-touch/work/=/product_id/RE166667.html").into(
        page_url: "https://www.dlsite.com/ecchi-eng-touch/work/=/product_id/RE166667.html",
      )
      should parse_url("https://www.dlsite.com/ecchi-eng/announce/=/product_id/RE155768.html").into(
        page_url: "https://www.dlsite.com/ecchi-eng/announce/=/product_id/RE155768.html",
      )
      should parse_url("https://eng.dlsite.com/work/=/product_id/RE036764").into(
        page_url: "https://www.dlsite.com/maniax/work/=/product_id/RE036764.html",
      )
      should parse_url("https://eng.dlsite.com/work/=/product_id/RE022725.html").into(
        page_url: "https://www.dlsite.com/maniax/work/=/product_id/RE022725.html",
      )
      should parse_url("http://maniax.dlsite.com/work/=/product_id/RJ072689.html").into(
        page_url: "https://www.dlsite.com/maniax/work/=/product_id/RJ072689.html",
      )

      should parse_url("https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689.html",
      )
      should parse_url("https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689.html").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689.html",
      )
      should parse_url("https://www.dlsite.com/maniax-touch/circle/profile/=/maker_id/RG64022.html").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG64022.html",
      )
      should parse_url("https://www.dlsite.com/home/circle/profile/=/maker_id/RG64308.html").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG64308.html",
      )
      should parse_url("https://www.dlsite.com/ecchi-eng/circle/profile/=/maker_id/RG05689.html").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG05689.html",
      )
      should parse_url("https://www.dlsite.com/girls/circle/profile/=/maker_id/RG70492.html").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG70492.html",
      )
      should parse_url("https://www.dlsite.com/bl/circle/profile/=/maker_id/RG11630.html").into(
        profile_url: "https://www.dlsite.com/maniax/circle/profile/=/maker_id/RG11630.html",
      )
      should parse_url("https://www.dlsite.com/books/author/=/author_id/AJ010529").into(
        profile_url: "https://www.dlsite.com/books/author/=/author_id/AJ010529",
      )
      should parse_url("https://www.dlsite.com/comic/author/=/author_id/AJ010529").into(
        profile_url: "https://www.dlsite.com/books/author/=/author_id/AJ010529",
      )
      should parse_url("https://www.dlsite.com/maniax/author/=/author_id/AJ010452").into(
        profile_url: "https://www.dlsite.com/books/author/=/author_id/AJ010452",
      )
    end
  end
end
