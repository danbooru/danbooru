require 'test_helper'

class UploadTest < ActiveSupport::TestCase
  context "In all cases" do
    setup do
      mock_iqdb_service!
      user = FactoryBot.create(:contributor_user)
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
          CurrentUser.user = FactoryBot.create(:user, :created_at => 1.year.ago)
          User.any_instance.stubs(:upload_limit).returns(0)
        end

        should "fail creation" do
          @upload = FactoryBot.build(:jpg_upload, :tag_string => "")
          @upload.save
          assert_equal(["You have reached your upload limit for the day"], @upload.errors.full_messages)
        end
      end

      context "image size calculator" do
        should "discover the dimensions for a compressed SWF" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/compressed.swf"))
          assert_equal([607, 756], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a JPG with JFIF data" do
          @upload = FactoryBot.create(:jpg_upload)
          assert_equal([500, 335], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a JPG with EXIF data" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/test-exif-small.jpg"))
          assert_equal([529, 600], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a JPG with no header data" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/test-blank.jpg"))
          assert_equal([668, 996], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a PNG" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/test.png"))
          assert_equal([768, 1024], @upload.calculate_dimensions)
        end

        should "discover the dimensions for a GIF" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/test.gif"))
          assert_equal([400, 400], @upload.calculate_dimensions)
          @upload = FactoryBot.create(:upload, :file_path => "#{Rails.root}/test/files/compressed.swf")
          @upload.calculate_dimensions
          assert_equal(607, @upload.image_width)
          assert_equal(756, @upload.image_height)
        end
      end

      context "content type calculator" do
        should "know how to parse jpeg, png, gif, and swf file headers" do
          @upload = FactoryBot.create(:jpg_upload)
          assert_equal("image/jpeg", @upload.file_header_to_content_type("#{Rails.root}/test/files/test.jpg"))
          assert_equal("image/gif", @upload.file_header_to_content_type("#{Rails.root}/test/files/test.gif"))
          assert_equal("image/png", @upload.file_header_to_content_type("#{Rails.root}/test/files/test.png"))
          assert_equal("application/x-shockwave-flash", @upload.file_header_to_content_type("#{Rails.root}/test/files/compressed.swf"))
          assert_equal("application/octet-stream", @upload.file_header_to_content_type("#{Rails.root}/README.md"))
        end

        should "know how to parse jpeg, png, gif, and swf content types" do
          @upload = FactoryBot.create(:jpg_upload)
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
            @upload = FactoryBot.create(:upload, file: upload_file("test/files/invalid_ugoira.zip"))
            @upload.process!
            assert_equal("error: RuntimeError - missing frame data for ugoira", @upload.status)
          end
        end

        context "that is a pixiv ugoira" do
          setup do
            @url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=46378654"
            @upload = FactoryBot.create(:source_upload, :source => @url, :tag_string => "ugoira")
            @output_file = Tempfile.new("download")
          end

          should "process successfully" do
            _, _, output_file = @upload.download_from_source(@url, "")
            assert_operator(output_file.size, :>, 1_000)
            assert_equal("zip", @upload.file_header_to_file_ext(output_file))
          end
        end

        should "initialize the final path after downloading a file" do
          @upload = FactoryBot.create(:source_upload)
          path = "#{Rails.root}/tmp/test.download.jpg"
          assert_nothing_raised {@upload.download_from_source(path)}
          assert(File.exists?(path))
          assert_equal(8558, File.size(path))
          assert_equal(path, @upload.file_path)
        end
      end

      context "determining if a file is downloadable" do
        should "classify HTTP sources as downloadable" do
          @upload = FactoryBot.create(:source_upload, :source => "http://www.example.com/1.jpg")
          assert_not_nil(@upload.is_downloadable?)
        end

        should "classify HTTPS sources as downloadable" do
          @upload = FactoryBot.create(:source_upload, :source => "https://www.example.com/1.jpg")
          assert_not_nil(@upload.is_downloadable?)
        end

        should "classify non-HTTP/HTTPS sources as not downloadable" do
          @upload = FactoryBot.create(:source_upload, :source => "ftp://www.example.com/1.jpg")
          assert_nil(@upload.is_downloadable?)
        end
      end

      context "file processor" do
        should "parse and process a cgi file representation" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/test.jpg"))
          assert_nothing_raised {@upload.process_upload}
          assert_equal(28086, @upload.file_size)
        end

        should "process a transparent png" do
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/alpha.png"))
          assert_nothing_raised {@upload.process_upload}
          assert_equal(1136, @upload.file_size)
        end
      end

      context "hash calculator" do
        should "caculate the hash" do
          @upload = FactoryBot.create(:jpg_upload)
          @upload.calculate_hash(@upload.file_path)
          assert_equal("ecef68c44edb8a0d6a3070b5f8e8ee76", @upload.md5)
        end
      end

      context "resizer" do
        should "generate several resized versions of the image" do
          @upload = FactoryBot.create(:large_jpg_upload)
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
        @upload = FactoryBot.create(:source_upload)
        assert_difference("CurrentUser.user.post_upload_count", 1) do
          @upload.process!
          CurrentUser.user.reload
        end
      end

      context "with an artist commentary" do
        setup do
          @upload = FactoryBot.create(:source_upload,
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
        @upload = FactoryBot.create(:source_upload,
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
          @upload = FactoryBot.build(:upload, file_ext: "png", file: upload_file("test/files/apng/normal_apng.png"))
          assert_equal("animated_png", @upload.automatic_tags)
        end

        should "tag animated gif files" do
          @upload = FactoryBot.build(:upload, file_ext: "gif", file: upload_file("test/files/test-animated-86x52.gif"))
          assert_equal("animated_gif", @upload.automatic_tags)
        end

        should "not tag static gif files" do
          @upload = FactoryBot.build(:upload, file_ext: "gif", file: upload_file("test/files/test-static-32x32.gif"))
          assert_equal("", @upload.automatic_tags)
        end
      end

      context "that is too large" do
        should "should fail validation" do
          Danbooru.config.stubs(:max_image_resolution).returns(31*31)
          @upload = FactoryBot.create(:upload, file: upload_file("test/files/test-static-32x32.gif"))
          @upload.process!
          assert_match(/image resolution is too large/, @upload.status)
        end
      end
    end

    should "process completely for a pixiv ugoira" do
      skip "ffmpeg is not installed" unless check_ffmpeg
      
      @upload = FactoryBot.create(:source_upload,
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
      assert_equal("https://i.pximg.net/img-zip-ugoira/img/2014/10/05/23/42/23/46378654_ugoira1920x1080.zip", post.source)
      assert_nothing_raised { post.file(:original) }
      assert_nothing_raised { post.file(:large) }
      assert_nothing_raised { post.file(:preview) }
    end

    should "process completely for an uploaded image" do
      @upload = FactoryBot.create(:jpg_upload,
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

    should "process completely for a .webm" do
      upload = FactoryBot.create(:upload, rating: "s", file: upload_file("test/files/test-512x512.webm"))

      assert_difference("Post.count") do
        assert_nothing_raised { upload.process! }
      end

      post = Post.last
      assert_includes(post.tag_array, "webm")
      assert_equal("webm", upload.file_ext)
      assert_equal(12345, upload.file_size)
      assert_equal(512, upload.image_width)
      assert_equal(512, upload.image_height)
      assert_equal("34dd2489f7aaa9e57eda1b996ff26ff7", upload.md5)

      assert_nothing_raised { post.file(:preview) }
      assert_nothing_raised { post.file(:original) }
    end

    should "process completely for a .mp4" do
      upload = FactoryBot.create(:upload, rating: "s", file: upload_file("test/files/test-300x300.mp4"))

      assert_difference("Post.count") do
        assert_nothing_raised { upload.process! }
      end

      post = Post.last
      assert_includes(post.tag_array, "mp4")
      assert_equal("mp4", upload.file_ext)
      assert_equal(18677, upload.file_size)
      assert_equal(300, upload.image_width)
      assert_equal(300, upload.image_height)
      assert_equal("865c93102cad3e8a893d6aac6b51b0d2", upload.md5)

      assert_nothing_raised { post.file(:preview) }
      assert_nothing_raised { post.file(:original) }
    end

    should "process completely for a null source" do
      @upload = FactoryBot.create(:jpg_upload, :source => nil)

      assert_difference("Post.count") do
        assert_nothing_raised {@upload.process!}
      end
    end

    should "delete the temporary file upon completion" do
      @upload = FactoryBot.create(:source_upload,
        :rating => "s",
        :uploader_ip_addr => "127.0.0.1",
        :tag_string => "hoge foo"
      )

      @upload.process!
      assert(!File.exists?(@upload.temp_file_path))
    end
  end
end
