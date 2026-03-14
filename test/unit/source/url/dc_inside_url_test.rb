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
        "https://m.dcinside.com/board/projectmx/11076518",
      )

      should be_profile_url(
        "https://gallog.dcinside.com/mannack0106",
        "https://m.dcinside.com/gallog/mannack0106",
      )
    end
  end
end
