require 'test_helper'

class UploadTest < ActiveSupport::TestCase
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
    end

    context "An upload" do
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
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/compressed.swf"))
          assert_equal([607, 756], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a JPG with JFIF data" do
          @upload = FactoryGirl.create(:jpg_upload)
          assert_equal([500, 335], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a JPG with EXIF data" do
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/test-exif-small.jpg"))
          assert_equal([529, 600], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a JPG with no header data" do
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/test-blank.jpg"))
          assert_equal([668, 996], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a PNG" do
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/test.png"))
          assert_equal([768, 1024], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a GIF" do
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/test.gif"))
          assert_equal([400, 400], @upload.calculate_dimensions)
        end
      end

      context "content type calculator" do
        should "know how to parse jpeg, png, gif, and swf file headers" do
          @upload = FactoryGirl.build(:jpg_upload)
          assert_equal("jpg", @upload.file_header_to_file_ext(File.open("#{Rails.root}/test/files/test.jpg")))
          assert_equal("gif", @upload.file_header_to_file_ext(File.open("#{Rails.root}/test/files/test.gif")))
          assert_equal("png", @upload.file_header_to_file_ext(File.open("#{Rails.root}/test/files/test.png")))
          assert_equal("swf", @upload.file_header_to_file_ext(File.open("#{Rails.root}/test/files/compressed.swf")))
          assert_equal("bin", @upload.file_header_to_file_ext(File.open("#{Rails.root}/README.md")))
        end
      end

      context "downloader" do
        context "for a zip that is not an ugoira" do
          should "not validate" do
            @upload = FactoryGirl.create(:upload, file: upload_file("test/files/invalid_ugoira.zip"))
            @upload.process!
            assert_equal("error: RuntimeError - missing frame data for ugoira", @upload.status)
          end
        end

        context "that is a pixiv ugoira" do
          setup do
            @url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654"
            @upload = FactoryGirl.create(:upload, :source => @url, :tag_string => "ugoira")
          end

          should "process successfully" do
            _, _, output_file = @upload.download_from_source(@url, "")
            assert_operator(output_file.size, :>, 1_000)
            assert_equal("zip", @upload.file_header_to_file_ext(output_file))
          end
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
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/test.jpg"))
          assert_nothing_raised {@upload.process_upload}
          assert_equal(28086, @upload.file_size)
        end

        should "process a transparent png" do
          @upload = FactoryGirl.create(:upload, file: upload_file("test/files/alpha.png"))
          assert_nothing_raised {@upload.process_upload}
          assert_equal(1136, @upload.file_size)
        end
      end

      context "hash calculator" do
        should "caculate the hash" do
          @upload = FactoryGirl.create(:jpg_upload)
          @upload.process_upload
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        end
      end

      context "resizer" do
        should "generate several resized versions of the image" do
          @upload = FactoryGirl.create(:upload, file_ext: "jpg", image_width: 1356, image_height: 911, file: upload_file("test/files/test-large.jpg"))
          preview_file, sample_file = @upload.generate_resizes
          assert_operator(preview_file.size, :>, 1_000)
          assert_operator(sample_file.size, :>, 1_000)
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
            include_artist_commentary: "1",
            artist_commentary_title: "",
            artist_commentary_desc: "blah",
          )
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

      context "automatic tagging" do
        should "tag animated png files" do
          @upload = FactoryGirl.build(:upload, file_ext: "png", file: upload_file("test/files/apng/normal_apng.png"))
          assert_equal("animated_png", @upload.automatic_tags)
        end

        should "tag animated gif files" do
          @upload = FactoryGirl.build(:upload, file_ext: "gif", file: upload_file("test/files/test-animated-86x52.gif"))
          assert_equal("animated_gif", @upload.automatic_tags)
        end

        should "not tag static gif files" do
          @upload = FactoryGirl.build(:upload, file_ext: "gif", file: upload_file("test/files/test-static-32x32.gif"))
          assert_equal("", @upload.automatic_tags)
        end
      end
    end

    should "process completely for a pixiv ugoira" do
      @upload = FactoryGirl.create(:source_upload, source: "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654")
      assert_difference(["PixivUgoiraFrameData.count", "Post.count"]) do
        @upload.process!
        assert_equal([], @upload.errors.full_messages)
      end
      post = Post.last
      assert_not_nil(post.pixiv_ugoira_frame_data)
      assert_equal("0d94800c4b520bf3d8adda08f95d31e2", post.md5)
      assert_equal(60, post.image_width)
      assert_equal(60, post.image_height)
      assert_equal("https://i.pximg.net/img-zip-ugoira/img/2014/10/05/23/42/23/46378654_ugoira1920x1080.zip", post.source)
      assert_nothing_raised { post.file(:original) }
      assert_nothing_raised { post.file(:large) }
      assert_nothing_raised { post.file(:preview) }
    end

    should "process completely for an uploaded image" do
      @upload = FactoryGirl.create(:jpg_upload,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo",
        :file => upload_file("test/files/test.jpg"),
        )

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
      assert_nothing_raised { post.file(:original) }
      assert_equal(28086, post.file(:original).size)
      assert_equal(post.id, @upload.post_id)
      assert_equal("completed", @upload.status)
    end

    should "process completely for a null source" do
      @upload = FactoryGirl.create(:jpg_upload, :source => nil)

      assert_difference("Post.count") do
        assert_nothing_raised {@upload.process!}
      end
    end
  end
end
