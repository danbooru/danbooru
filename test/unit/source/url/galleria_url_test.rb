require "test_helper"

module Source::Tests::URL
  class GalleriaUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://galleria-img.emotionflow.com/user_img9/40775/i660870_869.jpeg",
          "http://img01.emotionflow.com/galleria/user_img6/14169/141693874499122908405.png",
          "http://galleria.emotionflow.com/user_img6/12915/1291531674451216.png_480.jpg",
        ],
        page_urls: [
          "https://galleria.emotionflow.com/40775/660870.html",
          "https://galleria.emotionflow.com/s/40775/660870.html",
          "https://galleria.emotionflow.com/IllustDetailV.jsp?ID=136703&TD=701021",
          "https://galleria.emotionflow.com/s/IllustDetailV.jsp?ID=136703&TD=701021",
        ],
        profile_urls: [
          "http://galleria.emotionflow.com/GalleryListGridV.jsp?ID=15878",
          "http://galleria.emotionflow.com/s/GalleryListGridV.jsp?ID=15878",
          "http://galleria.emotionflow.com/MyGalleryListV.jsp?ID=40948",
          "https://galleria.emotionflow.com/40775/gallery.html",
          "https://galleria.emotionflow.com/s/40775/gallery.html",
          "https://galleria.emotionflow.com/40775/創作/",
          "http://temp.emotionflow.com/7289/",
        ],
      )
    end
  end
end
