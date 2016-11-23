require 'test_helper'

module Downloads
  class BCYTest < ActiveSupport::TestCase
    def setup
      super
      @record = false
      setup_vcr

      @single_work = "http://bcy.net/illust/detail/76491/919427"
      @single_full = "http://img9.bcyimg.com/drawer/76491/post/c04f6/8b8a2a90b14011e6bdbbb9a462d2fc4e.jpg"

      @login_only_work = "http://bcy.net/illust/detail/76491/919327"
      @login_only_full = "http://img9.bcyimg.com/drawer/76491/post/c04f6/b9f46310b12b11e6b11d09745c415615.jpg"

      @follower_only_work = "http://bcy.net/illust/detail/76490/919439"
      @follower_only_full = "http://img9.bcyimg.com/drawer/76490/post/c04f7/8321ff20b14211e6bd4bfb1d466f6563.jpg"

      @multiple_work = "http://bcy.net/illust/detail/76491/919312"

      # samples
      @cover = "http://img5.bcyimg.com/drawer/76491/cover/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg"
      @_2x2  = "http://img5.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg/2X2"
      @_2x3  = "http://img5.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg/2X3"
      @tl640 = "http://img5.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg/tl640"
      @w230  = "http://img5.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg/w230"
      @w650  = "http://img5.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg/w650"
      @watermarked = "http://img5.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg?imageMogr2/auto-orient/strip|watermark/2/text/wqlIYXNlbG51dHMKYmN5Lm5ldC91LzEzNzQwMDk=/fontsize/432/fill/I0U1RTVFNQ==/dx/6/dy/10/font/5b6u6L2v6ZuF6buR"

      # full images
      @full_jpg = "http://img9.bcyimg.com/drawer/76491/post/c04f6/342e28a0b12711e691db2d08ae08b1d2.jpg"
      @full_jpg_size = 10571

      @png      = "http://img5.bcyimg.com/drawer/76491/post/c04f6/c63112f0b12511e691db2d08ae08b1d2.png/w650"
      @full_png = "http://img9.bcyimg.com/drawer/76491/post/c04f6/c63112f0b12511e691db2d08ae08b1d2.png"
      @full_png_size = 62477

      @gif      = "http://img5.bcyimg.com/drawer/76491/post/c04f6/335aac00b12711e691db2d08ae08b1d2.gif/w650"
      @full_gif = "http://img9.bcyimg.com/drawer/76491/post/c04f6/335aac00b12711e691db2d08ae08b1d2.gif"
      @full_gif_size = 15048
    end

    def teardown
      Cache.delete(BCYWebAgent::CACHE_KEY)
    end

    context "bcy.net:" do
      context "Downloading a work page" do
        context "that has one image" do
          should "download the full size image" do
            assert_rewritten(@single_full, @single_work)
            assert_downloaded(10571, @single_work)
          end
        end

        context "that has multiple images" do
          should "download the first full size image" do
            assert_rewritten(@full_png, @multiple_work)
            assert_downloaded(@full_png_size, @multiple_work)
          end
        end

        context "that is login only" do
          should "download the full size image" do
            assert_rewritten(@login_only_full, @login_only_work)
            assert_downloaded(10571, @login_only_work)
          end
        end

        context "that is follower only" do
          should_eventually "download the full size image" do
            assert_rewritten(@follower_only_full, @follower_only_work)
            assert_downloaded(79166, @follower_only_work)
          end
        end
      end

      context" Downloading a sample image" do
        context "of type .png" do
          should "download the full size" do
	    assert_rewritten(@full_png, @png)
	    assert_downloaded(@full_png_size, @png)
          end
        end

        context "of type .gif" do
          should "download the full size" do
	    assert_rewritten(@full_gif, @gif)
	    assert_downloaded(@full_gif_size, @gif)
          end
        end

        context "of type /cover/" do
          should "download the full size" do
	    assert_rewritten(@full_jpg, @cover)
	    assert_downloaded(@full_jpg_size, @cover)
          end
        end

        context "of type /2X2" do
          should "download the full size" do
	    assert_rewritten(@full_jpg, @_2x2)
	    assert_downloaded(@full_jpg_size, @_2x2)
          end
        end

        context "of type /2X3" do
          should "download the full size" do
	    assert_rewritten(@full_jpg, @_2x3)
	    assert_downloaded(@full_jpg_size, @_2x3)
          end
        end

        context "of type /tl640" do
          should "download the full size" do
	    assert_rewritten(@full_jpg, @tl640)
	    assert_downloaded(@full_jpg_size, @tl640)
          end
        end

        context "of type /w230" do
          should "download the full size" do
	    assert_rewritten(@full_jpg, @w230)
	    assert_downloaded(@full_jpg_size, @w230)
          end
        end

        context "of type /w650" do
          should "download the full size" do
	    assert_rewritten(@full_jpg, @w650)
	    assert_downloaded(@full_jpg_size, @w650)
          end
        end

        context "of type ?imageMogr2" do
          should "download the full size" do
            assert_rewritten(@full_jpg, @watermarked)
            assert_downloaded(@full_jpg_size, @watermarked)
          end
        end
      end
    end
  end
end
