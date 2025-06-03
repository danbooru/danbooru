require "test_helper"

module Source::Tests::URL
  class NijieUrlTest < ActiveSupport::TestCase
    context "when parsing" do
      should_identify_url_types(
        image_urls: [
          "https://pic04.nijie.info/omata/4829_20161128012012.png",
          "https://pic01.nijie.info/nijie_picture/20120211210359.jpg",
          "https://pic03.nijie.info/nijie_picture/28310_20131101215959.jpg",
          "https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png ",
          "https://pic.nijie.net/07/nijie/17/95/728995/illust/0_0_403fdd541191110c_c25585.jpg",
          "https://pic.nijie.net/06/nijie/17/14/236014/illust/218856_1_7646cf57f6f1c695_f2ed81.png",
          "https://pic.nijie.net/03/nijie_picture/236014_20170620101426_0.png ",
          "https://pic.nijie.net/01/nijie_picture/diff/main/196201_20150201033106_0.jpg",
        ],
        page_urls: [
          "https://nijie.info/view.php?id=218856",
          "https://nijie.info/view_popup.php?id=218856",
          "https://www.nijie.info/view.php?id=218856",
          "https://sp.nijie.info/view.php?id=218856",
        ],
        profile_urls: [
          "https://nijie.info/members.php?id=236014",
          "https://nijie.info/members_illust.php?id=236014",
        ],
      )
    end

    context "when extracting attributes" do
      url_parser_should_work("https://pic01.nijie.info/nijie_picture/diff/main/218856_0_236014_20170620101329.png",
                             page_url: "https://nijie.info/view.php?id=218856",)

      url_parser_should_work("https://pic04.nijie.info/nijie_picture/diff/main/287736_161475_20181112032855_1.png",
                             page_url: "https://nijie.info/view.php?id=287736",)

      url_parser_should_work("http://pic02.nijie.info/nijie_picture/diff/main/0_23473_141_20120913002158.jpg",
                             page_url: nil,)
    end
  end
end
