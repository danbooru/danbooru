require "test_helper"

module Sources
  class DcInsideTest < ActiveSupport::TestCase
    context "A page URL" do
      strategy_should_work(
        "https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=11076518",
        image_urls: %w[https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b],
        media_files: [{ file_size: 2_512_536 }],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=11076518",
        profile_urls: %w[https://gallog.dcinside.com/mannack0106],
        display_name: "만낙",
        username: "mannack0106",
        tags: [],
        dtext_artist_commentary_title: "[🎨창작] 비키니 아로나",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "3db4c82ff39c28a8699fe8b115ef046fc4d64bbaa9f0":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081]
          가챠할때 빼고 아로나는 최고다
        EOS
      )
    end

    context "An image URL with a referer" do
      strategy_should_work(
        "https://image.dcinside.com/viewimage.php?id=&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b",
        referer: "https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=11076518",
        image_urls: %w[https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b],
        media_files: [{ file_size: 2_512_536 }],
        page_url: "https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=11076518",
        profile_urls: %w[https://gallog.dcinside.com/mannack0106],
        display_name: "만낙",
        username: "mannack0106",
        tags: [],
        dtext_artist_commentary_title: "[🎨창작] 비키니 아로나",
        dtext_artist_commentary_desc: <<~EOS.chomp
          "3db4c82ff39c28a8699fe8b115ef046fc4d64bbaa9f0":[https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081]
          가챠할때 빼고 아로나는 최고다
        EOS
      )
    end

    context "An image URL without a referer" do
      strategy_should_work(
        "https://image.dcinside.com/viewimage.php?id=&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b",
        image_urls: %w[https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b],
        media_files: [{ file_size: 2_512_536 }],
        page_url: nil,
        profile_urls: %w[],
        display_name: nil,
        username: nil,
        tags: [],
        dtext_artist_commentary_title: "",
        dtext_artist_commentary_desc: ""
      )
    end

    should "Parse DC Inside URLs correctly" do
      assert(Source::URL.image_url?("https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081&orgExt"))
      assert(Source::URL.image_url?("https://image.dcinside.com/viewimagePop.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b"))
      assert(Source::URL.image_url?("https://image.dcinside.com/viewimage.php?id=&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b"))
      assert(Source::URL.page_url?("https://gall.dcinside.com/mgallery/board/view?id=projectmx&no=11076518"))
      assert(Source::URL.profile_url?("https://gallog.dcinside.com/mannack0106"))
    end
  end
end
