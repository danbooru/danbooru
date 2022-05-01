require 'test_helper'

module Sources
  class Fc2Test < ActiveSupport::TestCase
    context "FC2:" do
      should "Parse FC2 URLs correctly" do
        assert(Source::URL.image_url?("http://onidocoro.blog14.fc2.com/file/20071003061150.png"))
        assert(Source::URL.image_url?("http://blog23.fc2.com/m/mosha2/file/uru.jpg"))
        assert(Source::URL.image_url?("http://blog.fc2.com/g/genshi/file/20070612a.jpg"))
        assert(Source::URL.image_url?("http://blog-imgs-63-origin.fc2.com/y/u/u/yuukyuukikansya/140817hijiri02.jpg"))
        assert(Source::URL.image_url?("http://blog-imgs-61.fc2.com/o/m/o/omochi6262/20130402080220583.jpg"))
        assert(Source::URL.image_url?("http://blog.fc2.com/g/b/o/gbot/20071023195141.jpg"))
        assert(Source::URL.image_url?("http://diary.fc2.com/user/yuuri/img/2005_12/26.jpg"))

        assert(Source::URL.profile_url?("http://silencexs.blog.fc2.com"))
        assert(Source::URL.profile_url?("http://794ancientkyoto.web.fc2.com"))
        assert(Source::URL.profile_url?("http://yorokobi.x.fc2.com"))
        assert(Source::URL.profile_url?("https://lilish28.bbs.fc2.com"))
        assert(Source::URL.profile_url?("http://jpmaid.h.fc2.com"))
        assert(Source::URL.profile_url?("http://swordsouls.blog131.fc2blog.net"))
        assert(Source::URL.profile_url?("http://swordsouls.blog131.fc2blog.us"))
      end
    end
  end
end
