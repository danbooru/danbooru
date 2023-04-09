require "test_helper"

module Sources
  class PlurkTest < ActiveSupport::TestCase
    context "A plurk post" do
      strategy_should_work(
        "https://www.plurk.com/p/om6zv4",
        image_urls: ["https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg"],
        media_files: [{ file_size: 627_697 }],
        artist_name: "紅眼兔@姑且是個畫圖的",
        tag_name: "redeyehare",
        profile_url: "https://www.plurk.com/redeyehare",
        dtext_artist_commentary_desc: "Trick or Treat!\n很久沒畫萬聖賀圖了，畫一波大的  感覺持續復健中"
      )
    end

    context "An adult plurk post" do
      strategy_should_work(
        "https://www.plurk.com/p/omc64y",
        profile_url: "https://www.plurk.com/BOW99",
        artist_name: "BOW🔞",
        tag_name: "BOW99",
        dtext_artist_commentary_desc: "[十月號]",
        image_urls: [
          "https://images.plurk.com/yfnumBJqqoQt50Em6xKwf.png",
          "https://images.plurk.com/5NaqqO3Yi6bQW1wKXq1Dc2.png",
          "https://images.plurk.com/3HzNcbMhCozHPk5YY8j9fI.png",
          "https://images.plurk.com/2e0duwn8BpSW9MGuUvbrim.png",
          "https://images.plurk.com/1OuiMDp82hYPEUn64CWFFB.png",
          "https://images.plurk.com/3F3KzZOabeMYkgTeseEZ0r.png",
          "https://images.plurk.com/7onKKTAIXkY4pASszrBys8.png",
          "https://images.plurk.com/6aotmjLGbtMLiI3slN7ODv.png",
          "https://images.plurk.com/6pzn7jE2nkj9EV7H25L0x1.png",
          "https://images.plurk.com/yA8egjDuhy0eNG9yxRj1d.png",
          "https://images.plurk.com/55tbTkH3cKTTYkZe9fu1Pv.png",
          "https://images.plurk.com/5z64F9uUipJ0fMJWXNGHTw.png",
          "https://images.plurk.com/6cwurMe6jymEu6INzmyg74.png",
          "https://images.plurk.com/7zyTReS8UVyCFYtU1DJRYt.png",
          "https://images.plurk.com/1PiRWGzaXozU15Scx1ZC4T.png",
          "https://images.plurk.com/2xzB5qacdLVV75GhaFifaY.png",
          "https://images.plurk.com/7uQENFmFNtWSKF0AAQKffr.png",
          "https://images.plurk.com/7ChGLokdAezvbEjPCLUr8f.png",
          "https://images.plurk.com/3AzjLxynamDGxNDTq4wt5x.png",
          "https://images.plurk.com/3SYjvKc3IBbz6ZXWeG1pY8.png",
          "https://images.plurk.com/7bk2kYN2fEVV0kiT5qoiuO.png",
          "https://images.plurk.com/6mgCwWjSqOfi0BtSg6THcZ.png",
          "https://images.plurk.com/3BwtMvr6S13gr96r5TLIFd.png",
          "https://images.plurk.com/22CPzkRM71frDR5eRMPthC.png",
          "https://images.plurk.com/1IFScoxA7m0FXNu6XirBwa.jpg",
          "https://images.plurk.com/5v1ZXQxbS7ocV4BybwbCSs.jpg",
          "https://images.plurk.com/4n1og7pg4KP3wRYSKpFzF7.png",
          "https://images.plurk.com/5gK1PyPTrVYoeZBr10lEYu.png",
          "https://images.plurk.com/3m8YZS3D9vaAH8Lw1LDTix.png",
          "https://images.plurk.com/3oy7joPrEFm0Wlo7NplXOl.png",
          "https://images.plurk.com/2IBA93ghmCJCJT72mQyLUK.png",
          "https://images.plurk.com/16jqEhVqtuLJwnRjpIDRCr.png",
          "https://images.plurk.com/7cKzaSigAvKc6DKNxeGmnH.png",
          "https://images.plurk.com/ypfkOMsC24hIPGSEWjJ8A.png",
          "https://images.plurk.com/5qW11yr06e9u3t5Zt9Jxmm.png",
          "https://images.plurk.com/4H5st1xsFDSFgLd7gNXgD8.png",
          "https://images.plurk.com/4nf49mWygwQyrYriZ453Qx.png",
          "https://images.plurk.com/2Y0TXcYZkni94j7yxxosV9.png",
          "https://images.plurk.com/5ih71C9XNJDq88wzKbBdNp.png",
          "https://images.plurk.com/UmoZjSHx0Y4NYa3mgKffU.png",
          "https://images.plurk.com/4IHGG5mQNw95vqClFEBoOM.png",
          "https://images.plurk.com/5J3bRPjGBZV8fDxo7cTwGs.png",
          "https://images.plurk.com/3uAjR5oBfe4d6MFThFQ0Gt.png",
          "https://images.plurk.com/3fFJ8RN3HkmfcuUdn7OpnQ.png",
          "https://images.plurk.com/sxkaWnhmDrCSsUEg6Kn9Y.png",
          "https://images.plurk.com/1f3W8JnHlwpt3OlT4ZJhiu.gif",
          "https://images.plurk.com/5lNGKqPCf6opXu21f5DdbU.gif",
        ]
      )
    end

    should "Parse Plurk URLs correctly" do
      assert(Source::URL.image_url?("https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg"))
      assert(Source::URL.image_url?("https://images.plurk.com/mx_5wj6WD0r6y4rLN0DL3sqag.jpg"))

      assert(Source::URL.page_url?("https://www.plurk.com/p/om6zv4"))
      assert(Source::URL.page_url?("https://www.plurk.com/m/p/okxzae"))

      assert(Source::URL.profile_url?("https://www.plurk.com/m/redeyehare"))
      assert(Source::URL.profile_url?("https://www.plurk.com/u/ddks2923"))
      assert(Source::URL.profile_url?("https://www.plurk.com/m/u/leiy1225"))
      assert(Source::URL.profile_url?("https://www.plurk.com/s/u/salmonroe13"))
      assert(Source::URL.profile_url?("https://www.plurk.com/redeyehare"))
    end
  end
end
