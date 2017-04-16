require 'test_helper'
require 'helpers/iqdb_test_helper'
require 'helpers/upload_test_helper'

class UploadTest < ActiveSupport::TestCase
  include IqdbTestHelper
  include UploadTestHelper

  def setup
    super

    mock_iqdb_service!
  end

  context "In all cases" do
    setup do
      user = FactoryGirl.create(:contributor_user)
      CurrentUser.user = user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil

      @upload.delete_temp_file if @upload
    end

    context "An upload" do
      teardown do
        FileUtils.rm_f(Dir.glob("#{Rails.root}/tmp/test.*"))
      end

      context "from a user that is limited" do
        setup do
          CurrentUser.user = FactoryGirl.create(:user, :created_at => 1.year.ago)
          User.any_instance.stubs(:upload_limit).returns(0)
        end
        
        should "fail creation" do
          @upload = FactoryGirl.build(:jpg_upload, :tag_string => "")
          @upload.save
          assert_equal(["You have reached your upload limit for the day"], @upload.errors.full_messages)
        end
      end

      context "image size calculator" do
        should "discover the dimensions for a compressed SWF" do
          @upload = FactoryGirl.create(:upload, :file_path => "#{Rails.root}/test/files/compressed.swf")
          @upload.calculate_dimensions(@upload.file_path)
          assert_equal(607, @upload.image_width)
          assert_equal(756, @upload.image_height)
        end

        should "discover the dimensions for a JPG with JFIF data" do
          @upload = FactoryGirl.create(:jpg_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(500, @upload.image_width)
          assert_equal(335, @upload.image_height)
        end

        should "discover the dimensions for a JPG with EXIF data" do
          @upload = FactoryGirl.create(:exif_jpg_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(529, @upload.image_width)
          assert_equal(600, @upload.image_height)
        end

        should "discover the dimensions for a JPG with no header data" do
          @upload = FactoryGirl.create(:blank_jpg_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(668, @upload.image_width)
          assert_equal(996, @upload.image_height)
        end

        should "discover the dimensions for a PNG" do
          @upload = FactoryGirl.create(:png_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(768, @upload.image_width)
          assert_equal(1024, @upload.image_height)
        end

        should "discover the dimensions for a GIF" do
          @upload = FactoryGirl.create(:gif_upload)
          assert_nothing_raised {@upload.calculate_dimensions(@upload.file_path)}
          assert_equal(400, @upload.image_width)
          assert_equal(400, @upload.image_height)
        end
      end

      context "content type calculator" do
        should "know how to parse jpeg, png, gif, and swf file headers" do
          @upload = FactoryGirl.create(:jpg_upload)
          assert_equal("image/jpeg", @upload.file_header_to_content_type("#{Rails.root}/test/files/test.jpg"))
          assert_equal("image/gif", @upload.file_header_to_content_type("#{Rails.root}/test/files/test.gif"))
          assert_equal("image/png", @upload.file_header_to_content_type("#{Rails.root}/test/files/test.png"))
          assert_equal("application/x-shockwave-flash", @upload.file_header_to_content_type("#{Rails.root}/test/files/compressed.swf"))
          assert_equal("application/octet-stream", @upload.file_header_to_content_type("#{Rails.root}/README.md"))
        end

        should "know how to parse jpeg, png, gif, and swf content types" do
          @upload = FactoryGirl.create(:jpg_upload)
          assert_equal("jpg", @upload.content_type_to_file_ext("image/jpeg"))
          assert_equal("gif", @upload.content_type_to_file_ext("image/gif"))
          assert_equal("png", @upload.content_type_to_file_ext("image/png"))
          assert_equal("swf", @upload.content_type_to_file_ext("application/x-shockwave-flash"))
          assert_equal("bin", @upload.content_type_to_file_ext(""))
        end
      end

      context "downloader" do
        context "for a zip that is not an ugoira" do
          should "not validate" do
            FileUtils.cp("#{Rails.root}/test/files/invalid_ugoira.zip", "#{Rails.root}/tmp")
            @upload = Upload.create(:file => upload_zip("#{Rails.root}/tmp/invalid_ugoira.zip"), :rating => "q", :tag_string => "xxx")
            @upload.process!
            assert_equal("error: RuntimeError - missing frame data for ugoira", @upload.status)
          end
        end

        context "that is a pixiv ugoira" do
          setup do
            @url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654"
            @upload = FactoryGirl.create(:source_upload, :source => @url, :tag_string => "ugoira")
            @output_file = Tempfile.new("download")
          end

          teardown do
            @output_file.unlink
          end
          
          should "process successfully" do
            @upload.download_from_source(@output_file.path)
            assert_operator(File.size(@output_file.path), :>, 1_000)
            assert_equal("application/zip", @upload.file_header_to_content_type(@output_file.path))
            assert_equal("zip", @upload.content_type_to_file_ext(@upload.file_header_to_content_type(@output_file.path)))
          end
        end

        should "initialize the final path after downloading a file" do
          @upload = FactoryGirl.create(:source_upload)
          path = "#{Rails.root}/tmp/test.download.jpg"
          assert_nothing_raised {@upload.download_from_source(path)}
          assert(File.exists?(path))
          assert_equal(8558, File.size(path))
          assert_equal(path, @upload.file_path)
        end
      end

      context "determining if a file is downloadable" do
        should "classify HTTP sources as downloadable" do
          @upload = FactoryGirl.create(:source_upload, :source => "http://www.example.com/1.jpg")
          assert_not_nil(@upload.is_downloadable?)
        end

        should "classify HTTPS sources as downloadable" do
          @upload = FactoryGirl.create(:source_upload, :source => "https://www.example.com/1.jpg")
          assert_not_nil(@upload.is_downloadable?)
        end

        should "classify non-HTTP/HTTPS sources as not downloadable" do
          @upload = FactoryGirl.create(:source_upload, :source => "ftp://www.example.com/1.jpg")
          assert_nil(@upload.is_downloadable?)
        end
      end

      context "file processor" do
        should "parse and process a cgi file representation" do
          FileUtils.cp("#{Rails.root}/test/files/test.jpg", "#{Rails.root}/tmp")
          @upload = Upload.new(:file => upload_jpeg("#{Rails.root}/tmp/test.jpg"))
          assert_nothing_raised {@upload.convert_cgi_file}
          assert(File.exists?(@upload.file_path))
          assert_equal(28086, File.size(@upload.file_path))
        end

        should "process a transparent png" do
          FileUtils.cp("#{Rails.root}/test/files/alpha.png", "#{Rails.root}/tmp")
          @upload = Upload.new(:file => upload_file("#{Rails.root}/tmp/alpha.png", "image/png", "alpha.png"))
          assert_nothing_raised {@upload.convert_cgi_file}
          assert(File.exists?(@upload.file_path))
          assert_equal(1136, File.size(@upload.file_path))
        end
      end

      context "hash calculator" do
        should "caculate the hash" do
          @upload = FactoryGirl.create(:jpg_upload)
          @upload.calculate_hash(@upload.file_path)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        end
      end

      context "resizer" do
        teardown do
          FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/preview/test.*.jpg"))
          FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/sample/test.*.jpg"))
          FileUtils.rm_f(Dir.glob("#{Rails.root}/public/data/test.*.jpg"))
        end

        should "generate several resized versions of the image" do
          @upload = FactoryGirl.create(:large_jpg_upload)
          @upload.calculate_hash(@upload.file_path)
          @upload.calculate_dimensions(@upload.file_path)
          assert_nothing_raised {@upload.generate_resizes(@upload.file_path)}
          assert(File.exists?(@upload.resized_file_path_for(Danbooru.config.small_image_width)))
          assert(File.size(@upload.resized_file_path_for(Danbooru.config.small_image_width)) > 0)
          assert(File.exists?(@upload.resized_file_path_for(Danbooru.config.large_image_width)))
          assert(File.size(@upload.resized_file_path_for(Danbooru.config.large_image_width)) > 0)
        end
      end

      should "increment the uploaders post_upload_count" do
        @upload = FactoryGirl.create(:source_upload)
        assert_difference("CurrentUser.user.post_upload_count", 1) do
          @upload.process!
          CurrentUser.user.reload
        end
      end

      context "with an artist commentary" do
        setup do
          @upload = FactoryGirl.create(:source_upload,
            :rating => "s",
            :uploader_ip_addr => "127.0.0.1",
            :tag_string => "hoge foo"
            )
          @upload.include_artist_commentary = "1"
          @upload.artist_commentary_title = ""
          @upload.artist_commentary_desc = "blah"
        end

        should "create an artist commentary when processed" do
          assert_difference("ArtistCommentary.count") do
            @upload.process!
          end
        end
      end

      should "process completely for a downloaded image" do
        @upload = FactoryGirl.create(:source_upload,
          :rating => "s",
          :uploader_ip_addr => "127.0.0.1",
          :tag_string => "hoge foo"
          )
        assert_difference("Post.count") do
          assert_nothing_raised {@upload.process!}
        end

        post = Post.last
        assert_equal("http://www.google.com/intl/en_ALL/images/logo.gif", post.source)
        assert_equal("foo hoge lowres", post.tag_string)
        assert_equal("s", post.rating)
        assert_equal(@upload.uploader_id, post.uploader_id)
        assert_equal("127.0.0.1", post.uploader_ip_addr.to_s)
        assert_equal(@upload.md5, post.md5)
        assert_equal("gif", post.file_ext)
        assert_equal(276, post.image_width)
        assert_equal(110, post.image_height)
        assert_equal(8558, post.file_size)
        assert_equal(post.id, @upload.post_id)
        assert_equal("completed", @upload.status)
      end
    end

    should "process completely for a pixiv ugoira" do
      @upload = FactoryGirl.create(:source_upload,
        :source => "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654",
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
        )
      assert_difference(["PixivUgoiraFrameData.count", "Post.count"]) do
        @upload.process!
        assert_equal([], @upload.errors.full_messages)
      end
      post = Post.last
      assert_not_nil(post.pixiv_ugoira_frame_data)
      assert_equal("0d94800c4b520bf3d8adda08f95d31e2", post.md5)
      assert_equal(60, post.image_width)
      assert_equal(60, post.image_height)
      assert_equal("https://i3.pixiv.net/img-zip-ugoira/img/2014/10/05/23/42/23/46378654_ugoira1920x1080.zip", post.source)
      assert_operator(File.size(post.large_file_path), :>, 0)
      assert_operator(File.size(post.preview_file_path), :>, 0)
    end

    should "process completely for an uploaded image" do
      @upload = FactoryGirl.create(:jpg_upload,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
        )
      @upload.file = upload_jpeg("#{Rails.root}/test/files/test.jpg")
      @upload.convert_cgi_file

      assert_difference("Post.count") do
        assert_nothing_raised {@upload.process!}
      end
      post = Post.last
      assert_equal("foo hoge lowres", post.tag_string)
      assert_equal("s", post.rating)
      assert_equal(@upload.uploader_id, post.uploader_id)
      assert_equal("127.0.0.1", post.uploader_ip_addr.to_s)
      assert_equal(@upload.md5, post.md5)
      assert_equal("jpg", post.file_ext)
      assert(File.exists?(post.file_path))
      assert_equal(28086, File.size(post.file_path))
      assert_equal(post.id, @upload.post_id)
      assert_equal("completed", @upload.status)
    end

    should "delete the temporary file upon completion" do
      @upload = FactoryGirl.create(:source_upload,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
        )

      @upload.process!
      assert(!File.exists?(@upload.temp_file_path))
    end
  end
end
