require 'test_helper'

module Downloads
  class TumblrTest < ActiveSupport::TestCase
    # Currently there's no way to obtain the raw version of these images,
    # so we have to change the tests to validate against the 1280 version
    
    context "a download for a tumblr 500 sample" do
      should "instead download the 1280 version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @ref = "https://noizave.tumblr.com/post/162206271767"
        @source = "https://24.media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_500.jpg"
        @rewrite = "https://media.tumblr.com/fc328250915434e66e8e6a92773f79d0/tumblr_mf4nshfibc1s0oswoo1_1280.jpg"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(113909, @source, @ref)
        # assert_downloaded(196_617, @source)
      end
    end

    context "a download for a *.media.tumblr.com/tumblr_$id_$size image without a larger size" do
      should "download the same version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @ref = "https://noizave.tumblr.com/post/162206271767"
        @source = "https://25.media.tumblr.com/tumblr_lxbzel2H5y1r9yjhso1_500.jpg"
        @rewrite = "https://media.tumblr.com/tumblr_lxbzel2H5y1r9yjhso1_1280.jpg"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(41803, @source, @ref)
        # assert_downloaded(90_122, @source)
      end
    end

    context "a download for a *.media.tumblr.com/tumblr_$id_$size image with a larger size" do
      should "download the best available version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @ref = "https://noizave.tumblr.com/post/162206271767"
        @source = "https://25.media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_500.png"
        @rewrite = "https://media.tumblr.com/tumblr_m2dxb8aOJi1rop2v0o1_1280.png"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(62658, @source, @ref)
      end
    end

    context "a download for a *.media.tumblr.com/$hash/tumblr_$id_rN_$size image" do
      should "download the best available version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @ref = "https://noizave.tumblr.com/post/162206271767"
        @source = "https://33.media.tumblr.com/4b7fecf9a5a8284fbaefb051a2369b55/tumblr_npozqfwc9h1rt6u7do1_r1_500.gif"
        @rewrite = "https://media.tumblr.com/4b7fecf9a5a8284fbaefb051a2369b55/tumblr_npozqfwc9h1rt6u7do1_r1_1280.gif"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(1_234_017, @source, @ref)
      end
    end

    context "a download for a *.media.tumblr.com/$hash/tumblr_inline_$id_$size image" do
      should "download the best available version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @source = "https://68.media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_250.gif"
        @rewrite = "https://media.tumblr.com/ee02048f5578595badc95905e17154b4/tumblr_inline_ofbr4452601sk4jd9_1280.gif"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(110_348, @source, @ref)
      end
    end

    context "a download for a media.tumblr.com/$id_$size image with a larger size" do
      should "download the best available version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @ref = "https://noizave.tumblr.com/post/162206271767"
        @source = "http://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_400.jpg"
        @rewrite = "https://media.tumblr.com/0DNBGJovY5j3smfeQs8nB53z_1280.jpg"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(122413, @source)
        # assert_downloaded(153_885, @source)
      end
    end

    context "a download for a media.tumblr.com/tumblr_$id_$size.jpg image" do
      should "download the best available version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @ref = "https://noizave.tumblr.com/post/162206271767"
        @source = "http://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_250.jpg"
        @rewrite = "https://media.tumblr.com/tumblr_m24kbxqKAX1rszquso1_1280.jpg"
        assert_rewritten(@rewrite, @source, @ref)
        assert_downloaded(101869, @source, @ref)
        # assert_downloaded(296_399, @source)
      end
    end

    context "a download for a *.tumblr.com/post/* html page" do
      should "download the best available version" do
        skip "Tumblr keys are not set" unless Danbooru.config.tumblr_consumer_key
        @source = "https://noizave.tumblr.com/post/162206271767"
        @rewrite = "https://media.tumblr.com/3bbfcbf075ddf969c996641b264086fd/tumblr_os2buiIOt51wsfqepo1_1280.png"

        assert_downloaded(3655, @source)
        assert_rewritten(@rewrite, @source)
      end
    end
  end
end
