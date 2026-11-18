require "test_helper"

module Source::Tests::URL
  class DcInsideUrlTest < ActiveSupport::TestCase
    context "DcInside URLs" do
      should be_image_url(
        "https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081&orgExt",
        "https://image.dcinside.com/viewimagePop.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b",
        "https://image.dcinside.com/viewimage.php?id=&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b",
      )

      should be_page_url(
        "https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=11076518",
        "https://gall.dcinside.com/board/view?id=idolmaster_new1&no=6840503",
        "https://gall.dcinside.com/mini/board/view?id=honkai3rd&no=5127",
        "https://gall.dcinside.com/m/projectmx/8472732",
        "https://gall.dcinside.com/mini/honkai3rd/5127",
        "https://gall.dcinside.com/idolmaster_new1/6840503",
        "https://m.dcinside.com/board/projectmx/11076518",
        "https://m.dcinside.com/mini/honkai3rd/5127",
      )

      should be_profile_url(
        "https://gallog.dcinside.com/mannack0106",
        "https://m.dcinside.com/gallog/mannack0106",
      )

      should_not be_page_url(
        "https://gall.dcinside.com/board/lists",
        "https://gall.dcinside.com/m/projectmx",
      )
    end

    should parse_url("https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081&orgExt").into(site_name: "DC Inside")

    should parse_url("https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=11076518").into(page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=11076518")
    should parse_url("https://gall.dcinside.com/m/projectmx/8472732").into(page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=8472732")
    should parse_url("https://gall.dcinside.com/board/view?id=idolmaster_new1&no=6840503").into(page_url: "https://gall.dcinside.com/board/view/?id=idolmaster_new1&no=6840503")
    should parse_url("https://gall.dcinside.com/idolmaster_new1/6840503").into(page_url: "https://gall.dcinside.com/board/view/?id=idolmaster_new1&no=6840503")
    should parse_url("https://gall.dcinside.com/mini/board/view?id=honkai3rd&no=5127").into(page_url: "https://gall.dcinside.com/mini/board/view/?id=honkai3rd&no=5127")
    should parse_url("https://gall.dcinside.com/mini/honkai3rd/5127").into(page_url: "https://gall.dcinside.com/mini/board/view/?id=honkai3rd&no=5127")
    should parse_url("https://m.dcinside.com/mini/honkai3rd/5127").into(page_url: "https://gall.dcinside.com/mini/board/view/?id=honkai3rd&no=5127")
  end
end
